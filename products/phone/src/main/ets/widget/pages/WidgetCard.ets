const storageDataFormCardByMessage = new LocalStorage()

@Entry(storageDataFormCardByMessage)
@Component
struct WidgetCard {
  fileNameList: string[] = new Array(2).fill('')
  @LocalStorageProp('message') message: string = ""

  /*
   * The title.
   */
  readonly title: string = '美蔻商城';
  /*
   * The action type.
   */
  readonly actionType: string = 'router';
  /*
   * The ability name.
   */
  readonly abilityName: string = 'PhoneAbility';
  /*
   * The message.
   */
  // readonly message: string = 'add detail';
  /*
   * The width percentage setting.
   */
  readonly fullWidthPercent: string = '100%';
  /*
   * The height percentage setting.
   */
  readonly fullHeightPercent: string = '100%';

  build() {
    Column() {
      Row() {
        Text(this.message)
          .fontColor($r('app.color.white'))
          .fontSize(16)
      }
      .height(40)
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Row() {
        ForEach(
          this.fileNameList,
          (url: string) => {
            Row() {
              Image('')
                .borderRadius(12)
                .width(50)
                .aspectRatio(1)
            }
            .backgroundColor('#eee')
            .borderRadius(12)
          }
        )
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .layoutWeight(1)
      .padding({
        left: 20,
        right: 20
      })
      .backgroundColor($r('app.color.white'))
      .borderRadius({
        topRight: 16,
        topLeft: 16
      })
      .onClick(() => {
        postCardAction(this, {
          action: this.actionType, // 拉起应用的模式
          abilityName: this.abilityName, // 拉起应用能力名称
          params: {
            // 卡片传递给应用的参数 应用在UIAbility里 冷启动onCreate 热启动onNewWant接收消息
            targetPage: "RecommendView"
          }
        })
      })
    }
    .linearGradient({
      angle: '135',
      colors: [
        [$r('app.color.linear_begin'), 0],
        [$r('app.color.linear_end'), 1]
      ]
    })
    .height('100%')
  }
}