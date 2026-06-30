import { HMRouter } from "@hadss/hmrouter";
import { StackAddress, WebComponent } from "basic";

@HMRouter({ pageUrl: StackAddress.PROFILE_WEB_PAGE })
@Component
export struct ProfileWebView {

  build() {
    Column() {
      WebComponent()
    }
    .width("100%")
    .height("100%")
  }
}

