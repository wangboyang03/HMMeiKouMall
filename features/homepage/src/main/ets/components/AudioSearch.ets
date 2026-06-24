import { AppSafeArea, ATManager, Logger } from "basic"
import { AppStorageV2, KeyboardAvoidMode } from "@kit.ArkUI"
import { speechRecognizer } from "@kit.CoreSpeechKit"
import { audio } from "@kit.AudioKit"

export enum VoiceState {
  DEFAULT,
  VOICING,
  VOICEOVER
}

@ComponentV2
export struct AudioSearch {
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  @Local voiceState: VoiceState = VoiceState.DEFAULT // 当前语音状态
  keyword?: string
  asrEngine?: speechRecognizer.SpeechRecognitionEngine
  audioCapturer?: audio.AudioCapturer
  @Event onChange: (keyword: string) => void = () => {}
  @Event onComplete: (keyword: string) => void = () => {}

  aboutToAppear(): void {
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE) // 键盘避让
  }

  async startRecord() {
    try {
      // 1. 使用录音识别引擎
      // 初始化引擎
      this.asrEngine = await speechRecognizer.createEngine({
        language: 'zh-CN', // 中文
        online: 1 // 在线识别
      })
      // 设置回调监听
      this.asrEngine.setListener({
        // 开始识别成功回调
        onStart(sessionId: string, eventMessage: string) {
          console.info(`onStart, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
        },
        // 事件回调
        onEvent(sessionId: string, eventCode: number, eventMessage: string) {
          console.info(`onEvent, sessionId: ${sessionId} eventCode: ${eventCode} eventMessage: ${eventMessage}`);
        },
        // 识别结果回调，包括中间结果和最终结果
        onResult(sessionId: string, result: speechRecognizer.SpeechRecognitionResult) {
          this.onChange(result.result)
          this.keyword = result.result
          Logger.info(sessionId, JSON.stringify(result))
        },
        // 识别完成回调
        onComplete(sessionId: string, eventMessage: string) {
          this.voiceState = VoiceState.DEFAULT
          this.onComplete(this.keyword)
          this.keyword = ""
          Logger.info(sessionId, JSON.stringify(eventMessage))
        },
        // 错误回调，错误码通过本方法返回
        onError(sessionId: string, errorCode: number, errorMessage: string) {
          console.error(`onError, sessionId: ${sessionId} errorCode: ${errorCode} errorMessage: ${errorMessage}`);
        }
      })

      // 调用开始识别方法
      this.asrEngine?.startListening({
        sessionId: '10000',
        audioInfo: {
          audioType: 'pcm',
          sampleRate: 16000,
          soundChannel: 1,
          sampleBit: 16
        }
      })

      // 2. 开启录音
      // 录音参数
      const audioStreamInfo: audio.AudioStreamInfo = {
        samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
        channels: audio.AudioChannel.CHANNEL_1,
        sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
        encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
      }
      const audioCapturerInfo: audio.AudioCapturerInfo = {
        source: audio.SourceType.SOURCE_TYPE_MIC,
        capturerFlags: 0
      }
      const audioCapturerOptions: audio.AudioCapturerOptions = {
        streamInfo: audioStreamInfo,
        capturerInfo: audioCapturerInfo
      }

      // 创建录音采集器
      this.audioCapturer = await audio.createAudioCapturer(audioCapturerOptions)
      // 注册事件
      this.audioCapturer.on('readData', (buffer) => {
        // 写入音频流
        this.asrEngine?.writeAudio('10000', new Uint8Array(buffer))
      })
      // 开始录音
      await this.audioCapturer.start()
      // 设置录音状态：录音中
      this.voiceState = VoiceState.VOICING
    } catch (error) {
    }
  }

  endRecord() {
    // 停止录音
    this.audioCapturer?.stop()
    // 释放录音采集器
    this.audioCapturer?.release()
    // 结束识别
    this.asrEngine?.finish('10000')
    // 释放语音识别引擎
    this.asrEngine?.shutdown()
    // 设置录音状态：录音结束
    this.voiceState = VoiceState.VOICEOVER
  }

  build() {
    Column() {
      // 提示文字
      if (this.voiceState != VoiceState.DEFAULT) {
        Column({ space: 16 }) {
          if (this.voiceState == VoiceState.VOICING) {
            Text('请说，我在聆听...')
              .fontSize(14)
            Text(this.keyword)
              .fontSize(14)
              .margin({
                top: 20
              })
          } else if (this.voiceState == VoiceState.VOICEOVER && this.keyword == "") {
            Text('未检测到语音，请长按按钮重试')
              .fontSize(14)
          }
          Text() {
            Span('你可以这样说：')
            Span('太阳眼镜/冬款连衣裙')
          }
          .fontSize(12)
          .fontColor($r('app.color.gray'))
        }
        .justifyContent(FlexAlign.Center)
        .height(150)
      }
      Blank()

      // 按钮
      Button() {
        Row({ space: 4 }) {
          Image($r('sys.media.ohos_ic_public_voice'))
            .width(16)
            .aspectRatio(1)
            .fillColor($r('app.color.white'))
          if (this.voiceState == VoiceState.VOICING) {
            Text('松开立即搜索')
              .fontSize(14)
              .fontColor($r('app.color.white'))
          } else {
            Text('长按语音搜索')
              .fontSize(14)
              .fontColor($r('app.color.white'))
          }
        }
      }
      .padding({ left: 12, right: 12 })
      .height(36)
      .linearGradient({
        angle: 135,
        colors: [[$r('app.color.linear_begin'), 0], [$r('app.color.linear_end'), 1]]
      })
      .margin({ bottom: 16 })
      .gesture(
        LongPressGesture() // 手势待处理
          .onAction(async () => {
            const res = await ATManager.getInstance().checkPermissions(["ohos.permission.MICROPHONE"])
            if (res) {
              // 处理录音逻辑
              this.startRecord()
            } else {
              this.getUIContext().getPromptAction().showToast({
                message: "请先到系统设置中开启美蔻商城麦克风权限"
              })
            }
          }) // 长按开始
          .onActionEnd(()=> this.endRecord()) // 长按结束
          .onActionCancel(() => this.endRecord()) // 取消长按
      )
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundImage($r('app.media.search_bg'))
    .backgroundImageSize(ImageSize.Contain)
    .backgroundImagePosition(Alignment.Bottom)
    .padding({
      bottom: this.safeAreaValue?.bottomHeight
    })
    .onVisibleAreaChange([0, 1], (_) => {
      // 重置状态
      this.voiceState = VoiceState.DEFAULT
      this.keyword = ""
    })
  }
}