import { HMRouter, HMRouterMgr } from "@hadss/hmrouter";
import { GuessingComponent, NavigationBar, StackAddress } from "basic";

interface PayResultResponse {
  orderId: string
  payResult: boolean
}

@HMRouter({pageUrl: StackAddress.PAY_RESULT_PAGE})
@ComponentV2
export struct PayResultView {
  @Local payResult: boolean = false
  @Local orderId: string = ''

  aboutToAppear(): void {
    const result = HMRouterMgr.getCurrentParam() as PayResultResponse
    if (result) {
      this.orderId = result.orderId
      this.payResult = result.payResult
    }
  }
  build() {
    Column() {
      NavigationBar({
        title: this.payResult ? '付款成功' : '付款失败',
        onLeftClick: () => HMRouterMgr.pop()
      })

      List() {
        ListItem() {
          Column({ space: 20 }) {
            Image(this.payResult ? $r('[basic].media.ic_public_check_filled') :
              $r('[basic].media.ic_public_close_filled'))
              .width(60)
              .height(60)
              .fillColor(this.payResult ? '#00C1BF' : '#B0171F')
            Text(this.payResult ? '付款成功' : '付款失败')
            Row({ space: 20 }) {
              Button('返回首页')
                .backgroundColor($r('[basic].color.black'))
                .fontSize(14)
                .height(36)
                .onClick(() => {

                })
              Button('查看订单')
                .fontSize(14)
                .height(36)
                .backgroundColor($r('[basic].color.white'))
                .fontColor($r('[basic].color.black'))
                .border({ width: 0.5, color: $r('[basic].color.border') })
                .onClick(() => {

                })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
          }
          .padding(40)
          .backgroundColor($r('[basic].color.under'))
        }

        ListItem() {
          GuessingComponent().height("100%")
        }
      }
      .layoutWeight(1)
      .height('100%')
      .width('100%')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.under'))
  }
}