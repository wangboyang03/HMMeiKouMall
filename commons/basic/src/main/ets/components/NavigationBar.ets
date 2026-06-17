import { AppSafeArea } from "../models"
import { AppStorageV2 } from "@kit.ArkUI"

@Preview
@ComponentV2
export struct NavigationBar {
  // 引入安全区高度
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  @Param title: string = "helloWorld"
  @Param leftIcon: ResourceStr = $r("app.media.ic_public_left")
  @Param rightIcon: ResourceStr = $r("app.media.ic_public_more")
  @Param showLeftIcon: boolean = true
  @Param showRightIcon: boolean = false
  @Param color: ResourceColor = $r("app.color.black")
  @Param bgColor: ResourceColor = $r("app.color.white")
  @Event onLeftClick: () => void = () => {}
  @Event onRightClick: () => void = () => {}
  @BuilderParam customTitle: () => void = this.defaultBuilder // 插槽

  @Builder defaultBuilder() {}

  build() {
    if (this.safeAreaValue) {
      RelativeContainer() {
        if (!!this.showLeftIcon) {
          Image(this.leftIcon)
            .width(20)
            .aspectRatio(1)
            .fillColor(this.color)
            .onClick(this.onLeftClick)
            .alignRules({
              center: {anchor: '__container__', align: VerticalAlign.Center}
            })
        }
        if (this.showRightIcon) {
          Image(this.rightIcon)
            .width(20)
            .aspectRatio(1)
            .fillColor(this.color)
            .onClick(this.onRightClick)
            .alignRules({
              right: {anchor: '__container__', align: HorizontalAlign.End},
              center: {anchor: '__container__', align: VerticalAlign.Center}
            })
        }

        if (this.title) {
          Text(this.title)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.color)
            .alignRules({
              center: {anchor: '__container__', align: VerticalAlign.Center},
              middle: {anchor: '__container__', align: HorizontalAlign.Center}
            })
        }

        if (this.customTitle) {
          this.customTitle() // 传入的UI结构
        }
      }
      .width('100%')
      .height(50+ this.safeAreaValue.topHeight)
      .padding({
        top: this.safeAreaValue.topHeight,
        right: 10,
        bottom: 0,
        left: 10
      })
      .backgroundColor(this.bgColor)
    }
  }
}