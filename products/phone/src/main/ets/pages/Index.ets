import { BreakPoint, BreakPointType, BreakPointEnum, TabItemParams, AppSafeArea, StackAddress, Constants,
  CartManager,
  CartCountObject} from 'basic'
import { CartView } from 'cart'
import { CategoryView } from 'category'
import { HomePageView } from 'homepage'
import { MineView } from 'mine'
import { AppStorageV2, AttributeUpdater } from '@kit.ArkUI'
import { HMNavigation } from '@hadss/hmrouter'
import { emitter } from '@kit.BasicServicesKit'

@Entry
@ComponentV2
struct Index {
  @Local activeIndex: number = 0
  list: TabItemParams[] = [
    { text: '首页', normal: $r('app.media.ic_public_home_normal'), active: $r('app.media.ic_public_home_active') },
    { text: '分类', normal: $r('app.media.ic_public_pro_normal'), active: $r('app.media.ic_public_pro_active') },
    { text: '购物袋', normal: $r('app.media.ic_public_cart_normal'), active: $r('app.media.ic_public_cart_active') },
    { text: '我的', normal: $r('app.media.ic_public_my_normal'), active: $r('app.media.ic_public_my_active') },
  ]
  breakPointObject = AppStorageV2.connect(BreakPoint, () => new BreakPoint())
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  modifier: MyNavModifier = new MyNavModifier()
  tabsController: TabsController = new TabsController()
  appCart?: CartCountObject = AppStorageV2.connect(CartCountObject, () => new CartCountObject())

  async aboutToAppear(): Promise<void> {
    this.registerEvent()
    await CartManager.getInstance().updateCartCount()
  }

  /**
   * 注册事件
   */
  registerEvent() {
    emitter.on(Constants.SWITCH_HOMEPAGE, (event) => {
      if (!!event.data) {
        // this.activeIndex = event.data.index as number
        this.tabsController.changeIndex(event.data.index as number)
      }
    })
  }


  build() {
    Stack() {
      HMNavigation({
        navigationId: StackAddress.MAIN_PAGE_ID,
        homePageUrl: StackAddress.MAIN_PAGE,
        options: {
          modifier: this.modifier
        }
      }) {
        Tabs({ controller: this.tabsController, index: this.activeIndex!!, barPosition: new BreakPointType({
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
        .padding({
          bottom: this.safeAreaValue?.bottomHeight
        })
      }
    }
  }

  @Builder
  TabItemBuilder(item: TabItemParams, index: number) {
    Column() {
      if (index == 2) {
        Badge({
          count: this.appCart?.count,
          style: {}
        }) {
          Column({ space: 5 }) {
            Image(this.activeIndex == index ? item.active : item.normal)
              .width(24)
              .aspectRatio(1)
            Text(item.text)
              .fontColor($r('app.color.black'))
              .fontSize(12)
          }
        }
      } else {
        Image(this.activeIndex == index ? item.active : item.normal)
          .width(24)
          .aspectRatio(1)
        Text(item.text)
          .fontColor($r('app.color.black'))
          .fontSize(12)
      }
    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .height(50)
  }
}

class MyNavModifier extends AttributeUpdater<NavigationAttribute> {
  // 重写AttributeUpdater里的方法
  initializeModifier(instance: NavigationAttribute): void {
    // instance就是Navigation实例对象
    instance.hideTitleBar(true); // 隐藏标题栏
    instance.mode(NavigationMode.Stack) // 单栏模式
    instance.titleMode(NavigationTitleMode.Mini) // 标题模式全屏
  }
}