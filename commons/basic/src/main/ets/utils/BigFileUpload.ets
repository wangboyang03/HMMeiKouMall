import { common } from '@kit.AbilityKit'
import { fileIo, fileUri, picker } from '@kit.CoreFileKit'
import { Logger } from '.'
import { cryptoFramework } from '@kit.CryptoArchitectureKit'
import { buffer } from '@kit.ArkTS'
import { rcp } from '@kit.RemoteCommunicationKit'

/**
 * 文件上传接口
 */
interface UploadRequest {
  context: common.Context
  filePath: string
  fileName: string
  chunkSize: number
  onProgress: (progress: number) => void
}

interface ResponseBasic<T> {
  success: boolean
  message: string
  data: T
}

interface ChunksQueryResponse {
  fileHash: string
  uploadedChunks: number[]
}

interface ChunksQueryRequest {
  fileHash: string
}

interface FileMergeRequest {
  fileHash: string
  fileName: string
  totalChunks: number
}

interface PickFileResponse {
  filePath: string
  fileName: string
}

export class FileUploadUtil {
  private static sInstance: FileUploadUtil
  private readonly DEFAULT_CHUNK_SIZE = 2 * 1024 * 1024 // 文件切片大小 2mb
  private readonly BASE_URL = "http://192.168.43.10:3000" // 服务器地址
  private session = rcp.createSession()

  private constructor() {} // 私有构造函数

  /**
   * 单例实例
   * @returns
   */
  static getInstance(): FileUploadUtil {
    if (!FileUploadUtil.sInstance) {
      FileUploadUtil.sInstance = new FileUploadUtil()
    }
    return FileUploadUtil.sInstance
  }

  /**
   * 专属的网络请求
   */
  async _request<T>(url: string, method: rcp.HttpMethod, data?: Object, query?: object) {
    try {
      let finalUrl = url
      if (query) {
        // 1.拼接Query参数
        const queryString = Object.keys(query).filter(key => !!query[key]).map(key => `${key}=${query[key]}`).join('&')
        finalUrl += `?${queryString}`
      }
      // 2. 发送请求
      const request = new rcp.Request(finalUrl, method, { 'Content-Type': 'application/json' }, data)
      const res = await this.session.fetch(request)
      return res.toJSON() as ResponseBasic<T>
    } catch (error) {
      Logger.error('出错了', error)
      return
    }
  }

  /**
   * 文件上传
   */
  async upload(options: UploadRequest) {
    try {
      // 1. 获取文件信息
      const chunkSize = options.chunkSize ?? this.DEFAULT_CHUNK_SIZE
      const fileStat = fileIo.statSync(options.filePath)
      const totalChunks = Math.ceil(fileStat.size / chunkSize) // 文件切片数量
      // 2. 计算哈希值
      const fileHash = await this.createFileHash(options.filePath)
      // 3. 获取切片信息 调用查询接口
      // const res = await NetworkRequestUtil.get<ResponseBasic<ChunksQueryResponse>>(`/api/upload/check`, {fileHash} as ChunksQueryRequest)
      const res = await this._request<ChunksQueryResponse>(`${this.BASE_URL}/api/upload/check`, 'GET', undefined, {fileHash} as ChunksQueryRequest)
      console.log('check raw res = ', JSON.stringify(res))
      if (res && res.data.uploadedChunks.length > 0) {
        // 存在返回值 不是首次上传 是断点续传
      }
      const uploadedSet = new Set<number>(res?.data?.uploadedChunks ?? [])
      // 4. 切片上传
      const startTime = Date.now()
      const chunksUpload: number[] = []
      for (let i = 0; i < totalChunks; i++) {
        if (!uploadedSet.has(i)) {
          chunksUpload.push(i)
        }
      }
      // 5.微队列上传
      const CONCURRENCY = 3 // 最大并发数
      let index = 0
      const task = async () => {
        while (true) {
          const i = index++
          if (i >= chunksUpload.length) {
            break
          }
          const chunkIndex = chunksUpload[i]
          const state = await this.uploadSingleChunk(options, chunkIndex, totalChunks, fileHash, chunkSize)

          if (!!state) {
            const progress = Math.floor(((uploadedSet.size + i + 1) / totalChunks) * 100)
            options.onProgress(progress)
          }
        }
      }
      const tasks: Promise<void>[] = []
      for (let i = 0; i < CONCURRENCY; i++) {
        tasks.push(task())
      }
      await Promise.all(tasks)

      // 6.合并文件
      const merge = await this._request<PickFileResponse>(`${this.BASE_URL}/api/upload/merge`, 'POST', {
        fileHash,
        fileName: options.fileName,
        totalChunks
      } as FileMergeRequest)
      Logger.info(merge)
      if (merge?.success) {
        const endTime = Date.now()
        Logger.info(`上传完成，耗时：${endTime - startTime}ms`)
      }
    } catch (error) {
      console.log('error:', error)
      console.log('message:', error?.message)
      console.log('response:', error?.response)
    }
  }

  /**
   * 文件哈希值计算
   * @param filePath 文件路径
   * @returns fileHash 文件哈希值
   */
  private async createFileHash(filePath: string) {
    try {
      const md = cryptoFramework.createMd('MD5')
      const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY)
      const fileSize = fileIo.statSync(filePath).size
      let offset: number = 0
      while (offset < fileSize) {
        const size = Math.min(this.DEFAULT_CHUNK_SIZE, fileSize - offset)
        const buffer = new ArrayBuffer(size)
        const len = fileIo.readSync(file.fd, buffer, {
          offset: offset,
          length: size
        })
        if (len > 0) {
          const uint8Array = new Uint8Array(buffer.slice(0, len))
          const blob: cryptoFramework.DataBlob = { data: uint8Array }
          await md.update(blob)
        }
        offset += size
      }
      fileIo.closeSync(file)
      const mdOutput = await md.digest()
      return buffer.from(mdOutput.data).toString('hex')
    } catch (error) {
      Logger.error(error) // 文件读取错误
      return ""
    }
	}

  /**
   * 上传单个分片
   */
  private async uploadSingleChunk(options: UploadRequest, chunkIndex: number, totalChunks: number, fileHash: string, chunkSize: number) {
    try {
      const fileSize = fileIo.statSync(options.filePath).size
      const start = chunkIndex * chunkSize
      const end = Math.min(start + chunkSize, fileSize)
      const file = fileIo.openSync(options.filePath, fileIo.OpenMode.READ_ONLY)
      const buffer = new ArrayBuffer(end - start)
      // const reader = fileIo.readSync(file.fd, buffer, {
      //   offset: start,
      //   length: end - start
      // })

      const content: rcp.FileContent = { content: buffer }
      // const content= rcp.FormFieldFileValue('multipart/form-data', options.fileName, file.path)
      const multiFormFieldValue: rcp.MultipartFormFieldValue = {
        remoteFileName: options.fileName,
        contentType: "multipart/form-data",
        contentOrPath: content
      }

      const simpleFrom = new rcp.MultipartForm({
        "chunk": multiFormFieldValue,
        "fileHash": fileHash,
        "chunkIndex": String(chunkIndex),
        "totalChunks": String(totalChunks),
        "fileName": options.fileName
      })

      try {
        const request = new rcp.Request(this.BASE_URL+'/api/upload/chunk', 'POST', { 'Content-Type': 'multipart/form-data' }, simpleFrom)
        const session = rcp.createSession()
        const res = (await this.session.fetch(request)).toJSON()
        // Logger.info(res)
        return true
      } catch (error) {
        Logger.error('发送网络请求失败', error)
        return false
      }
      // const result = await this._request<PickFileResponse>(`${FileUploadUtil.BASE_URL}/api/upload/chunk`, 'POST', undefined, form)
    } catch (error) {
      Logger.error('上传单个切片文件失败', error)
      return false
    }
  }

  /**
   * 从文件管理器中选择文件
   * @returns
   */
  async selectFileFromManager() {
    try {
      const documentPicker = new picker.DocumentViewPicker()
      const options = new picker.DocumentSelectOptions()
      const result = await documentPicker.select(options)
      if (result && result.length > 0) {
        const uri = result[0]
        const file = fileIo.openSync(uri)
        const fileName = file.path.substring(file.path.lastIndexOf('/') + 1)
        return {
          filePath: file.path,
          fileName
        } as PickFileResponse
      }
      return
    } catch (error) {
      Logger.error(error)
      return
    }
  }

  /**
   * 构建表单数据
   * @param fileName 文件名
   * @param pathOrContent 文件路径或文件内容
   * @param contentType 文件类型
   * @returns 表单数据
   */
  private buildMultipartFormFieldValue(fileName: string | undefined, pathOrContent: rcp.Path | rcp.FileContent | rcp.GetDataCallback, contentType: string | undefined): rcp.MultipartFormFieldValue {
    const result: rcp.MultipartFormFieldValue = {
      remoteFileName: fileName,
      contentType: contentType,
      contentOrPath: pathOrContent
    }
    return result
  }
}