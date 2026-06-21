import { HMRouter } from "@hadss/hmrouter";
import { NavigationBar, StackAddress } from "basic";

@HMRouter({ pageUrl: StackAddress.ADD_ADDRESS_PAGE })
@Component
export struct AddAddressView {

  build() {
    Column() {
      NavigationBar({
        title: "新增地址"
      })

    }
    .width("100%")
    .height("100%")
    .backgroundColor($r('app.color.under'))


  }
}