import { BreakPoint, BreakPointType, BreakPointEnum, TabItemParams } from 'basic'
import { CartView } from 'cart'
import { CategoryView } from 'category'
import { HomePageView } from 'homepage'
import { MineView } from 'mine'
import { AppStorageV2 } from '@kit.ArkUI'

@Entry
@ComponentV2
struct Index {
  @Local
  activeIndex: number = 0
  list: TabItemParams[] = [
    { text: '首页', normal: $r('app.media.ic_public_home_normal'), active: $r('app.media.ic_public_home_active') },
    { text: '分类', normal: $r('app.media.ic_public_pro_normal'), active: $r('app.media.ic_public_pro_active') },
    { text: '购物袋', normal: $r('app.media.ic_public_cart_normal'), active: $r('app.media.ic_public_cart_active') },
    { text: '我的', normal: $r('app.media.ic_public_my_normal'), active: $r('app.media.ic_public_my_active') },
  ]
  breakPointObject = AppStorageV2.connect(BreakPoint, () => new BreakPoint())

  build() {
    Tabs({ index: this.activeIndex!!, barPosition: new BreakPointType({
      sm: BarPosition.End,
      md: BarPosition.End,
      lg: BarPosition.Start
    }).getValue(this.breakPointObject?.breakPoint)}) {
      ForEach(this.list, (item: TabItemParams, index: number) => {
        TabContent() {
          if (index == 0) {
            HomePageView()
          } else if (index == 1) {
            CategoryView()
          } else if (index == 2) {
            CartView()
          } else if (index == 3) {
            MineView()
          }
        }
        .tabBar(this.TabItemBuilder(item, index))
      })
    }
    .scrollable(false)
    .vertical(
      new BreakPointType({
        sm: false,
        md: false,
        lg: true
      }).getValue(this.breakPointObject?.breakPoint ?? BreakPointEnum.SM)
    )
    .barHeight(
      new BreakPointType({
        sm: 60,
        md: 60,
        lg: 450
      }).getValue(this.breakPointObject?.breakPoint ?? BreakPointEnum.SM)
    )
    .divider({
      strokeWidth: 1
    })
    .onTabBarClick(index => {
      this.activeIndex = index
    })
  }

  @Builder
  TabItemBuilder(item: TabItemParams, index: number) {
    Column() {
      Image(this.activeIndex == index ? item.active : item.normal)
        .width(24)
        .aspectRatio(1)
      Text(item.text)
        .fontColor($r('app.color.black'))
        .fontSize(12)
    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .height(50)
  }
}