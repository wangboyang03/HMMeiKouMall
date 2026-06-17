import { common } from '@kit.AbilityKit'
import { fileIo } from '@kit.CoreFileKit'
import { Logger } from '.'
import request from '@ohos.request'

/**
 * 文件上传接口
 */
interface UploadRequest {
  context: common.UIAbilityContext // UIAbility上下文对象
  filePath: string // 文件路径
  fileName: string // 文件名
  url: string // 上传地址
  chunkSize?: number // 分片大小
  onProgress?: (progress: number) => void // 上传进度
}

export class FileUploadUtil {
  private static sInstance: FileUploadUtil
  private readonly DEFAULT_CHUNK_SIZE = 2 * 1024 * 1024 // 文件切片大小 2mb
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
   * 文件上传
   */
  async upload(options: UploadRequest) {
    try {
      const chunkSize = options?.chunkSize ?? this.DEFAULT_CHUNK_SIZE // 切片大小
      const stat = fileIo.statSync(options.filePath) // 获取文件信息
      const fileSize = stat.size // 文件大小
      const totalChunk = Math.ceil(fileSize / chunkSize) // 总切片数
      Logger.info(`fileSize,${fileSize}, chunkSize,${chunkSize}, totalChunk,${totalChunk}`)

      for (let chunkIndex = 0; chunkIndex < totalChunk; chunkIndex++) {
        // 调用上传单个分片的方法
        this.uploadSingleChunk(options, chunkIndex, totalChunk)
        const progress = Math.floor(((chunkIndex + 1) / totalChunk) * 100)
        options.onProgress?.(progress)
      }
      // 调用合并文件的方法
      // await this.mergeFile(options)
    } catch (error) {
      Logger.error(error)
    }
  }

  /**
   * 合并文件
   * @param options 上传文件参数
   */
  private mergeFile(options: UploadRequest) {}

  /**
   * 上传单个分片
   * @param options 上传文件参数
   * @param chunkIndex 分片索引
   * @param totalChunk 总切片数
   */
  private async uploadSingleChunk(options: UploadRequest, chunkIndex: number, totalChunk: number) {
    const uploadConfig: request.UploadConfig = {
      url: options.url,
      method: 'POST',
      header: {
        chunkIndex: `${chunkIndex}`,
        totalChunk: `${totalChunk}`,
        fileName: options.fileName
      },
      files: [
        {
          filename: options.fileName,
          name: 'file',
          uri: options.filePath,
          type: 'bin'
        }
      ],
      data: []
    }
    await request.uploadFile(options.context, uploadConfig)
  }
}