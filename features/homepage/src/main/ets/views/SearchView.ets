import { AppSafeArea, StackAddress } from 'basic'
import { AppStorageV2 } from '@kit.ArkUI'
import { HMRouter, HMRouterMgr } from '@hadss/hmrouter'

@HMRouter({ pageUrl: StackAddress.SEARCH_PAGE })
@ComponentV2
export struct SearchView {
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  @Local keyword: string = ''

  build() {
    Column() {
      // search
      Row() {
        Image($r('app.media.ic_public_left'))
          .width(24)
          .aspectRatio(1)
          .fillColor($r('app.color.white'))
          .margin(13)
          .onClick(() => HMRouterMgr.pop())
        Search({ placeholder: '商品关键字...', value: this.keyword })
          .searchIcon({ src: $r('app.media.ic_public_search'), color: $r('app.color.gray') })
          .placeholderColor($r('app.color.gray'))
          .placeholderFont({ size: 14 })
          .searchButton('搜索', { fontSize: 14, fontColor: $r('app.color.red') })
          .backgroundColor($r('app.color.white'))
          .textFont({ size: 14 })
          .layoutWeight(1)
          .padding(0)
          .margin(0)
          .height(36)
          .caretStyle({ color: $r('app.color.red') })
          .defaultFocus(true)
          .onSubmit((value) => {})
      }
      .padding({ top: this.safeAreaValue?.topHeight, right: 16 })
      .linearGradient({
        angle: 135,
        colors: [[$r('app.color.linear_begin'), 0], [$r('app.color.linear_end'), 1]]
      })
      // 语音搜索组件
    }
  }
}

