// 参考链接：https://developer.huawei.com/consumer/cn/doc/harmonyos-references/hms-ai-texttospeech#texttospeechengine
import { textToSpeech } from "@kit.CoreSpeechKit";
import { Logger } from "./Logger";

export class TextToSpeechEngine {
  private static sInstance: TextToSpeechEngine
  private ttsEngine?: textToSpeech.TextToSpeechEngine // 语音合成引擎
  private constructor() {} // 私有构造函数

  /**
   * 获取单例实例
   * @returns
   */
  public static getInstance(): TextToSpeechEngine {
    if (!TextToSpeechEngine.sInstance) {
      TextToSpeechEngine.sInstance = new TextToSpeechEngine()
    }
    return TextToSpeechEngine.sInstance
  }

  /**
   * 文本转语音
   * @param text 传入需要阅读的文本
   */
  async speakFromText(text: string) {
    // 1.初始化文本转语音引擎
    try {
      // 设置创建引擎参数
      let extraParam: Record<string, Object> = {
        'style': 'interaction-broadcast', // 广播风格
        'locate': 'CN' // 地区
      }
      let createEngineParams: textToSpeech.CreateEngineParams = {
        language: 'zh-CN', // 语言
        person: 13, // 13聆小珊女声音色 21凌飞哲男声音色 8英语劳拉女声
        online: 1, // 目前只支持离线模式
        extraParams: extraParam
      }
      const res = await textToSpeech.createEngine(createEngineParams)
      if (res) {
        this.ttsEngine = res // 已经拿到实例对象 初始化完毕了
      }
    } catch (error) {
      Logger.error(error)
    }
    // 2. 创建引擎成功后开始进行语音合成
    if (!!this.ttsEngine) {
      const listener: textToSpeech.SpeakListener = {
        onStart() {},
        onComplete() {},
        onStop() {},
        onData() {},
        onError: (requestId, errorCode, errorMessage) => {
          Logger.error(`requestId: ${requestId}, errorCode: ${errorCode}, errorMessage: ${errorMessage}`)
        }
      }
      this.ttsEngine.setListener(listener) // 设置监听器
      const extraParam: Record<string, Object> = {
        'queueMode': 0, // 播报模式 0排队模式播报 1抢占模式播报
        'speed': 1, // 语速 一倍语速合成音频流
        'volume': 2, // 音量 一倍音量合成音频流
        'pitch': 1, // 语调 正常音调合成音频流
        'languageContext': 'zh-CN', // 语言环境 目前只有中文
        'audioType': 'pcm', // 音频类型 pcm
        'soundChannel': 3, // 语音助手频道
        'playType': 1 // 合成与播报不返回音频流
      }
      const params: textToSpeech.SpeakParams = {
        requestId: String(Date.now()),
        extraParams: extraParam
      }
      try {
        this.ttsEngine.speak(text, params)
      } catch (error) {
        Logger.error(`文字转语音失败,${error}`)
      }
    }
  }
}