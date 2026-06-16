import { media } from "@kit.MediaKit"
import { audio } from "@kit.AudioKit"
import { Logger } from "."
import { promptAction } from "@kit.ArkUI"


export class SoundPool {
  private static sInstance: SoundPool
  private soundPool?: media.SoundPool
  private constructor() {} // 私有构造函数

  // 单例实例
  public static getInstance(): SoundPool {
    if (SoundPool.sInstance == null) {
      SoundPool.sInstance = new SoundPool()
    }
    return SoundPool.sInstance
  }

  /**
   * 初始化音频池
   */
  private async init() {
    try {
      if (this.soundPool) {
        return
      }
      const audioRendererInfo: audio.AudioRendererInfo = {
        usage: audio.StreamUsage.STREAM_USAGE_MUSIC, // 音频流使用类型 音乐
        rendererFlags: 0 // 音频渲染器标志
      }
      this.soundPool = await media.createSoundPool(5, audioRendererInfo) // 创建音频池实例
    } catch (error) {
      Logger.error(error)
    }
  }

  /**
   * 播放音频
   * @param context 上下文对象
   * @param moduleName 当前rawfile文件所处的模块名
   * @param fileName rawfile中的文件名
   */
  async play(context: Context, moduleName: string, fileName: string) {
    try {
      // 1.初始化 创建音频池实例
      await this.init()
      let soundId: number | undefined // 声明音频ID
      if (!!this.soundPool) {
        // 2.获取当前模块的上下文对象
        const currentContext = context.getApplicationContext().createModuleContext(moduleName)
        // 3.获取文件句柄
        const fileFd = currentContext.resourceManager.getRawFdSync(fileName)
        // 4.加载音频文件
        soundId = await this.soundPool.load(fileFd.fd, fileFd.offset, fileFd.length)
      }
      // 5.注册音频加载完成监听器
      this.soundPool?.on('loadComplete', () => {
        // 6.组装播放参数对象
        const params: media.PlayParameters = {
          loop: 0, // 循环0次，即播放1次
          rate: 1, // 1倍速播放
          leftVolume: 0.5, // 左声道音量
          rightVolume: 0.5, // 右声道音量
          priority: 0 // 优先级
        }
        // 7.开始播放
        this.soundPool?.play(soundId, params)
      })
      // 8.注册播放完成监听器
      this.soundPool?.on('playFinished', () => {
        // 9.执行清理
        this.soundPool?.off('loadComplete')
        this.soundPool?.off('playFinished')
        this.soundPool?.release()
      })

    } catch (error) {
      promptAction.openToast({ message: "播放短音失败" })
      Logger.error('播放失败', error)
    }
  }
}