import { AppSafeArea } from "basic"
import { AppStorageV2, KeyboardAvoidMode } from "@kit.ArkUI"

export enum VoiceState {
  DEFAULT,
  VOICING,
  VOICEOVER
}

@Component
export struct AudioSearch {
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  @State voiceState: VoiceState = VoiceState.DEFAULT // 当前语音状态
  keyword?: string

  aboutToAppear(): void {
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE) // 键盘避让
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
  }
}