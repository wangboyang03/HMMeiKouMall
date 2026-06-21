import { AppSafeArea, AppUserObject, BreakPoint, CartGoodsObject, CartGoodsItemModel, Constants, GuessingComponent, NavigationBar, StackAddress,
  NetworkRequestUtil,
  CartManager,
  CartItemRequest,
  LoadingCustomDialog} from 'basic'
import { HMRouter, HMRouterMgr } from '@hadss/hmrouter'
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI'
import { CartItem } from '../components'
import { EmptyComponent } from '../components'
import { emitter } from '@kit.BasicServicesKit'

@HMRouter({pageUrl: StackAddress.CART_PAGE }) // 添加路由跳转注解
@ComponentV2
export struct CartView {
  breakPointObject?: BreakPoint = AppStorageV2.connect(BreakPoint, () => new BreakPoint())
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  appUser?: AppUserObject = PersistenceV2.connect(AppUserObject, () => new AppUserObject())
  // @Local cartList: CartGoodsItemModel[] = []
  @Local isShowLeftIcon: boolean = HMRouterMgr.getCurrentParam() as boolean
  appCart?: CartGoodsObject = AppStorageV2.connect(CartGoodsObject, () => new CartGoodsObject())
  @Computed get isAllSelected() {
    return this.appCart?.cartGoodsList.every(item => item.selected)
  }
  loadingDialog = new CustomDialogController({
    builder: LoadingCustomDialog({
      message: "正在修改购物车,请稍后..."
    }),
    customStyle: true,
    alignment: DialogAlignment.Center
  })

  aboutToAppear(): void {

  }

  onCheckOrder() {
    AlertDialog.show({
      message: '去结算'
    })
  }

  build() {
    Column() {
      NavigationBar({
        showLeftIcon: this.isShowLeftIcon,
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
          // 已登录状态下
          if (this.appCart?.cartGoodsList.length) {
            // 购物车内有商品
            ForEach(this.appCart.cartGoodsList, (cart: CartGoodsItemModel) => {
              ListItem() {
                CartItem({
                  cart: cart,
                  onChangeSelected: async selected => {
                    this.loadingDialog.open()
                    await NetworkRequestUtil.put<null>(`${Constants.CART_MODIFY_API}/${cart.skuId}`, {
                      count: String(cart.count),
                      selected
                    } as CartItemRequest)
                    // 刷新购物车数据
                    await CartManager.getInstance().updateCartCount()
                    this.loadingDialog.close()
                  },
                  onChangeCount: async count => {
                    this.loadingDialog.open()
                    // this.getUIContext().getPromptAction().showToast({ message: String(count) })
                    await NetworkRequestUtil.put<null>(`${Constants.CART_MODIFY_API}/${cart.skuId}`, {
                      count: String(count),
                      selected: cart.selected
                    } as CartItemRequest)
                    // 刷新购物车数据
                    await CartManager.getInstance().updateCartCount()
                    this.loadingDialog.close()
                  }
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
              EmptyComponent({
                onBtnClick: () => emitter.emit(Constants.SWITCH_HOMEPAGE, {
                  data: {
                    index: 0
                  }
                })
              })
            }
          }
        } else {
          // 未登录
          ListItem() {
            EmptyComponent({
              tip: '您还没有登录~',
              buttonText: '去登录',
              onBtnClick: () => HMRouterMgr.push({
                pageUrl: StackAddress.LOGIN_PAGE
              })
            })
          }
        }
        ListItem() {
          GuessingComponent().margin({ top: 8, bottom: 8 })
        }
      }
      .width('100%')
      .height('100%')
      .contentStartOffset(8)
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      if (this.appCart?.cartGoodsList.length) {
        Row() {
          Checkbox()
            .selectedColor($r('app.color.red'))
            .select(this.isAllSelected)
            .onClick(async () => {
              this.loadingDialog.open()
              await NetworkRequestUtil.put<null>(Constants.CART_SELECTED_API, {
                selected: !this.isAllSelected
              } as CartItemRequest)
              await CartManager.getInstance().updateCartCount() // 更新购物车数据
              this.loadingDialog.close()
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
            .enabled(this.appCart.cartGoodsList.some(item => item.selected))
            .fontSize(14)
            .height(36)
            .backgroundColor($r('app.color.red'))
            .onClick(() => {})
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

  @Builder DeleteBuilder(cart: CartGoodsItemModel) {
    Text('删除')
      .fontSize(14)
      .width(60)
      .height(100)
      .backgroundColor($r('app.color.red'))
      .fontColor($r('app.color.white'))
      .textAlign(TextAlign.Center)
      .onClick(() => {})
  }
}