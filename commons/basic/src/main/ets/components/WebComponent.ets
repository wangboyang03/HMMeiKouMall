import { AppSafeArea } from "../models"
import { AppStorageV2 } from "@kit.ArkUI"
import { webview } from "@kit.ArkWeb"
import { HMRouterMgr } from "@hadss/hmrouter"

@Component
export struct WebComponent {
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  @Prop title: string = "美寇商城"
  @Prop src: ResourceStr = "m.taobao.com"
  @State isLoading: boolean = false
  @State progress: number = 0
  controller: webview.WebviewController = new webview.WebviewController()
  @State historyCurrIndex: number = 0
  @State historySize: number = 0

  build() {
    Column() {
      this.NavigationBar()

      Stack({
        alignContent: Alignment.Top
      }) {
        if (this.isLoading) {
          // 进度条
          Progress({
            value: this.progress,
            total: 100,
            type: ProgressType.Linear,
          })
            .style({
              strokeWidth: 2,
              enableSmoothEffect: true
            })
            .color($r('app.color.red'))
            .zIndex(1)
        }
        Web({
          controller: this.controller,
          src: this.src
        })
          .onPageBegin(() => {
            this.progress = 0
            this.isLoading = true
          })
          .onProgressChange((data: OnProgressChangeEvent) => {
            if (!!data) {
              this.progress = data.newProgress
              this.getUIContext().animateTo({
                duration: 300,
                delay: 300
              }, () => this.isLoading = data.newProgress == 100 ? false : true)
            }
          })
          // 加载网页页面完成时触发该回调，用于应用更新其访问的历史链接
          .onRefreshAccessedHistory(() => {
            const history = this.controller.getBackForwardEntries()  // 获取当前Webview的历史信息列表
            this.historyCurrIndex = history.currentIndex  // 当前在页面历史列表中的索引
            this.historySize = history.size  // 历史列表中索引的数量，最多保存50条，超过时起始记录会被覆盖
            // AlertDialog.show({message: this.historyCurrIndex + '-' + this.historySize })
          })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.under'))
  }

  @Builder NavigationBar() {
    Column(){
      if (!!this.safeAreaValue) {
        // 导航条
        Row() {
          Row() {
            Image($r("app.media.ic_public_left"))
              .iconStyle()
              .onClick(() => {
                // back
                if (this.historyCurrIndex > 0) {
                  this.controller.backward()
                } else {
                  HMRouterMgr.pop()
                }
              })
            Image($r('app.media.ic_public_close'))
              .iconStyle()
              .onClick(() => {
                HMRouterMgr.pop()
              })
          }
          .width(100)

          Text(this.title)
            .fontSize(16)
            .fontWeight(500)
            .fontColor($r('app.color.black'))
            .layoutWeight(1)
            .maxLines(1)
            .textAlign(TextAlign.Center)
            .textOverflow({ overflow: TextOverflow.MARQUEE })
          Row() {
            Blank()
            Image($r('app.media.ic_public_more'))
              .iconStyle()
              .bindMenu(this.MenuBuilder)
          }
          .width(100)
        }
        .height(50 + this.safeAreaValue.topHeight)
        .backgroundColor($r('app.color.white'))
        .padding({ top: this.safeAreaValue.topHeight })
      }
    }
    .width('100%')
    .backgroundColor($r('app.color.under'))
  }

  @Builder MenuBuilder() {
    Menu() {
      MenuItem({ content: '首页' })
        .onClick(() => {})
      MenuItem({ content: '分类' })
        .onClick(() => {})
      MenuItem({ content: '购物袋' })
        .onClick(() => {})
      MenuItem({ content: '我的' })
        .onClick(() => {})
      MenuItem({ content: '刷新一下' })
        .onClick(() => {})
    }
    .width(100)
    .fontColor($r('app.color.text'))
    .font({ size: 14 })
    .radius(4)
  }

}

@Extend(Image) function iconStyle() {
  .width(24)
  .aspectRatio(1)
  .fillColor($r('app.color.text'))
  .margin(13)
}