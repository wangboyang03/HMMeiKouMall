import { Context } from "@kit.AbilityKit";
import { request, SuppressWarnings, SuppressWarningsType } from "@kit.BasicServicesKit";
import { fileIo } from "@kit.CoreFileKit";
import HashMap from "@ohos.util.HashMap";

export class DownloadManager {
  private static sInstance: DownloadManager;
  private constructor() {}

  public static getInstance(): DownloadManager {
    if (!DownloadManager.sInstance) {
      DownloadManager.sInstance = new DownloadManager();
    }
    return DownloadManager.sInstance;
  }

  /**
   * 下载图片集合列表
   * @param string[] urls 图片地址集合
   * @returns Promise<string[]>
   */
  downloadImageList(context: Context, urls: string[]) {
    return Promise.all(urls.map((url): Promise<string> => this.downloadImage(context, url)))
  }

  /**
   * 下载单张图片
   */
  downloadImage(context: Context, url: string) {
    try {
      return new Promise<string>(async (resolve, reject) => {
        const tempDir = context.tempDir
        const filePath = tempDir + '/' + Date.now() + '.jpg' // 沙箱临时目录下的图片文件路径

        @SuppressWarnings({ rules: [SuppressWarningsType.PERMISSION] }) // 消除网络权限申请的警告
        const task = await request.downloadFile(context, {
          url,
          filePath
        })
        task.on("progress", () => {
          // 做进度监听
        })
        task.on("complete", () => {
          resolve(filePath)
        })
        // 下载异常或失败
        task.on("fail", () => {
          reject(new Error("下载失败"))
        })
      });
    } catch (error) {
      return Promise.reject(error)
    }
  }

  /**
   * 创建表单图片集合
   * @param string[] list
   * @returns Map<string, number>
   */
  createFormImages(list: string[]) {
    // const formImages = new Map<string, number>()
    // list.forEach((path: string) => {
    //   // 1.根据文件名称打开文件
    //   const file = fileIo.openSync(path)
    //   formImages.set(path, file.fd)
    // })
    // return formImages
    const formImages: Record<string, number> = {}
    list.forEach((path: string) => {
      // 1.根据文件名称打开文件
      const file = fileIo.openSync(path)
      formImages[path] = file.fd
    })
    return formImages
  }
}