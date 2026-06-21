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

export interface ResponseBasic<T> {
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

interface chuckResponse {
  fileHash: string
  chunkIndex: number
  totalChunks: number
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
  private static readonly BASE_URL = "http://192.168.43.10:3000" // 服务器地址
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
      const res = await this._request<ChunksQueryResponse>(`${FileUploadUtil.BASE_URL}/api/upload/check`, 'GET', undefined, {fileHash} as ChunksQueryRequest)
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
      // await NetworkRequestUtil.post<null>(`${FileUploadUtil.BASE_URL}/api/upload/merge`, {
      //   fileHash,
      //   fileName: options.fileName,
      //   totalChunks
      // } as FileMergeRequest)
      const merge = await this._request<PickFileResponse>(`${FileUploadUtil.BASE_URL}/api/upload/merge`, 'POST', {
        fileHash,
        fileName: options.fileName,
        totalChunks
      } as FileMergeRequest)
      Logger.info(merge)
      if (merge?.success) {
        const endTime = Date.now()
        Logger.info(`上传完成，耗时：${endTime - startTime}ms`)
      }
      const endTime = Date.now()
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
      const reader = fileIo.readSync(file.fd, buffer, {
        offset: start,
        length: end - start
      })

      // const res = await this.session.uploadFromFile(`${FileUploadUtil.BASE_URL}/api/upload/chunk`, new rcp.UploadFromFile(reader))

      // const tempPath = `${options.context.cacheDir}/chunk_${chunkIndex}.tmp` // 临时文件路径
      // const tempFile = fileIo.openSync(tempPath, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC)
      // fileIo.writeSync(tempFile.fd, buffer)
      // fileIo.closeSync(file)
      // const chunkUint8Array = new Uint8Array(buffer)

      // const boundary = '----ohos' + Date.now()
      // const body = this.buildMultipartBody(
      //   boundary,
      //   {
      //     "fileHash": fileHash,
      //     "chunkIndex": String(chunkIndex),
      //     "totalChunks": String(totalChunks),
      //     "fileName": options.fileName
      //   },
      //   'chunk',
      //   chunkUint8Array
      // )
      // const request = new rcp.Request(
      //   `${FileUploadUtil.BASE_URL}/api/upload/chunk`,
      //   'POST',
      //   {
      //     'Content-Type': `multipart/form-data; boundary=${boundary}`
      //   },
      //   body
      // )

      const form = new rcp.Form({
        chunk: reader,
        fileHash,
        chunkIndex: String(chunkIndex),
        totalChunks: String(totalChunks),
        fileName: options.fileName
      })
      const request = new rcp.Request(
        `${FileUploadUtil.BASE_URL}/api/upload/chunk`,
        'POST',
        { 'Content-Type': `multipart/form-data` },
        form
      )
      const res = (await this.session.fetch(request)).toString()
      Logger.info( res)
      // const result = await this._request<PickFileResponse>(`${FileUploadUtil.BASE_URL}/api/upload/chunk`, 'POST', undefined, form)


      // Logger.info(result)
      // if (!result?.success) {
      //   Logger.error('上传单个切片文件失败', result?.message)
      //   return false
      // }
      return true
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
   * 构造multipartBody
   * @param boundary
   * @param fields
   * @param fileFieldName
   * @param fileData
   * @returns Uint8Array
   */
  buildMultipartBody(boundary: string, fields: Record<string, string>, fileFieldName: string, fileData: Uint8Array): Uint8Array {
    const CRLF = '\r\n'
    const encode = (str: string): Uint8Array => new Uint8Array(buffer.from(str).buffer)
    const parts: Uint8Array[] = []

    // 普通字段
    const keys = Object.keys(fields)
    for (let i = 0; i < keys.length; i++) {
      const key = keys[i]
      parts.push(encode(`--${boundary}${CRLF}`))
      parts.push(encode(`Content-Disposition: form-data; name="${key}"${CRLF}${CRLF}`))
      parts.push(encode(fields[key] + CRLF))
    }

    // 文件字段
    parts.push(encode(`--${boundary}${CRLF}`))
    parts.push(encode(`Content-Disposition: form-data; name="${fileFieldName}"; filename="chunk.bin"${CRLF}`))
    parts.push(encode(`Content-Type: application/octet-stream${CRLF}${CRLF}`))
    parts.push(fileData)
    parts.push(encode(CRLF))

    // 结束
    parts.push(encode(`--${boundary}--${CRLF}`))

    // merge
    let total = 0
    for (let i = 0; i < parts.length; i++) {
      total += parts[i].length
    }

    const result = new Uint8Array(total)
    let offset = 0
    for (let i = 0; i < parts.length; i++) {
      result.set(parts[i], offset)
      offset += parts[i].length
    }
    return result
  }
}