import { HMRouter, HMRouterMgr } from "@hadss/hmrouter";
import { AppSafeArea, Constants, LoadingCustomDialog, StackAddress } from "basic";
import { webview } from "@kit.ArkWeb";
import { AppStorageV2 } from "@kit.ArkUI";

@HMRouter({ pageUrl: StackAddress.PAY_PAGE })
@ComponentV2
export struct PayView {
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  orderId: string = "" // 订单号
  controller: webview.WebviewController = new webview.WebviewController()
  loadingDialog = new CustomDialogController({
    builder: LoadingCustomDialog({
      message: "网页正在加载中",
    }),
    customStyle: true,
    alignment: DialogAlignment.Center,
  });

  aboutToAppear(): void {
    this.loadingDialog.open()
    this.orderId = HMRouterMgr.getCurrentParam()  as string
  }

  build() {
    Column() {
      // Web组件 src地址: https://meikou-api.itheima.net/pay/wap/aliPay?orderId=订单id
      Web({
        controller: this.controller,
        src: `${Constants.BASE_URL}/pay/wap/aliPay?orderId=${this.orderId}`
      }).onPageEnd((_) => {
        this.loadingDialog.close()
      })
    }
    .width("100%")
    .height("100%")
    .padding({
      top: this.safeAreaValue?.topHeight,
      bottom: this.safeAreaValue?.bottomHeight
    })
  }
}