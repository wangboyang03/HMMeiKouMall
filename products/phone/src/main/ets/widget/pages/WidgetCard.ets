@Entry
@Component
struct WidgetCard {
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
  readonly message: string = 'add detail';
  /*
   * The width percentage setting.
   */
  readonly fullWidthPercent: string = '100%';
  /*
   * The height percentage setting.
   */
  readonly fullHeightPercent: string = '100%';

  build() {
    Row() {
      Column() {
        Text(this.title)
          .fontSize($r('app.float.font_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font'))
      }
      .width(this.fullWidthPercent)
    }
    .height(this.fullHeightPercent)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .onClick(() => {
      postCardAction(this, {
        action: this.actionType, // 拉起应用的模式
        abilityName: this.abilityName, // 拉起应用能力名称
        params: {
          // 卡片传递给应用的参数 应用在UIAbility里 冷启动onCreate 热启动onNewWant接收消息
          message: this.message
        }
      });
    })
  }
}