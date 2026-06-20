import { AppSafeArea, AppUserObject, BreakPoint, CartGoodsItemModel, GuessingComponent, NavigationBar } from 'basic'
import { HMRouterMgr } from '@hadss/hmrouter'
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI'
import { CartItem } from '../components'


@ComponentV2
export struct CartView {
  breakPointObject?: BreakPoint = AppStorageV2.connect(BreakPoint, () => new BreakPoint())
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  appUser?: AppUserObject = PersistenceV2.connect(AppUserObject, () => new AppUserObject())
  @Local cartList: CartGoodsItemModel[] = []

  aboutToAppear(): void {

  }

  @Builder
  DeleteBuilder(cart: CartGoodsItemModel) {
    Text('删除')
      .fontSize(14)
      .width(60)
      .height(100)
      .backgroundColor($r('app.color.red'))
      .fontColor($r('app.color.white'))
      .textAlign(TextAlign.Center)
      .onClick(() => {

      })
  }

  onCheckOrder() {
    AlertDialog.show({
      message: '去结算'
    })
  }

  build() {
    Column() {
      NavigationBar({
        onLeftClick: () => HMRouterMgr.pop(),
        title: '购物袋',
        showRightIcon: true
      })
        .border({
          width: { bottom: 0.5 },
          color: '#e4e4e4'
        })

      List() {
        if (this.appUser?.User.token) {

          if (this.cartList.length) {
            ForEach(this.cartList, (cart: CartGoodsItemModel) => {
              ListItem() {
                CartItem({
                  cart: cart,
                  onChangeSelected: async selected => {}
                })
              }
              .backgroundColor($r('app.color.under'))
              .padding({ left: 8, right: 8 })
              .transition({ type: TransitionType.Delete, opacity: 0 })
              .swipeAction({
                end: this.DeleteBuilder(cart)
              })
            })
          } else {
            ListItem() {

            }
          }
        } else {
          // 未登录
          ListItem() {


          }
        }
        ListItem() {
          GuessingComponent().margin({ top: 8, bottom: 8 })
        }
      }
      .contentStartOffset(8)
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      if (this.cartList.length) {
        Row() {
          Checkbox()
            .selectedColor($r('app.color.red'))
            .onClick(async () => {

            })
          Text('全选')
            .fontSize(14)
            .fontColor($r('app.color.black'))
            .margin({ right: 20 })
          Text('合计:')
            .fontSize(14)
            .fontColor($r('app.color.black'))
            .margin({ right: 2 })
          Text("0.00")
            .fontSize(16)
            .fontWeight(500)
            .fontColor($r('app.color.red'))
            .layoutWeight(1)
          Button('去结算')
            .enabled(this.cartList.some(item => item.selected))
            .fontSize(14)
            .height(36)
            .backgroundColor($r('app.color.red'))
            .onClick(() => {

            })
        }
        .height(50)
        .width('100%')
        .backgroundColor($r('app.color.white'))
        .border({
          width: { top: 0.5, bottom: 0.5 },
          color: '#e4e4e4'
        })
        .padding({ left: 16, right: 16 })
      }
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.under'))

  }
}