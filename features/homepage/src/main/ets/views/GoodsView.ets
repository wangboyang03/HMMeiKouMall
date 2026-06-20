import { Goods } from '../models'
import { AppStorageV2, PromptAction } from '@kit.ArkUI'
import { GoodsInformation, GoodsComment, GoodsDetail } from '../components'
import { HMRouter, HMRouterMgr } from '@hadss/hmrouter'
import { AppSafeArea, BreakPoint, GuessingComponent, LoadingCustomDialog, NavigationBar,
  Sku,
  SkuType, StackAddress,
  UserAuth } from 'basic'
import { addGoodsToCartApi, getGoodsDetailApi } from '../api'


@HMRouter({ pageUrl: StackAddress.GOODS_PAGE })
@ComponentV2
export struct GoodsView {
  breakPointObject?: BreakPoint = AppStorageV2.connect(BreakPoint, () => new BreakPoint())
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  @Local goods: Goods = {} as Goods
  @Local activeIndex: number = 0
  @Local loading: boolean = false
  @Local showSheet: boolean = false
  @Local sku: SkuType = {} as SkuType
  scroller = new Scroller()
  tabsList: string[] = ["商品", "评价", "详情", "推荐"]
  loadingDialog = new CustomDialogController({
    builder: LoadingCustomDialog({
      message: '新鲜内容马上就来'
    }),
    customStyle: true,
    alignment: DialogAlignment.Center
  })
  @Local counterNumber: number = 1 // 购物车数量
  promptAction: PromptAction = this.getUIContext().getPromptAction()

  aboutToAppear(): void {
    this.goods = HMRouterMgr.getCurrentParam() as Goods
    if (this.goods.id) {
      this.getGoodsDetailData()
    }
  }

  /**
   * 获取商品详情
   */
  async getGoodsDetailData() {
    this.loadingDialog.open()
    this.goods = await getGoodsDetailApi({
      id: this.goods.id
    })
    this.loadingDialog.close()
  }

  /**
   * 添加购物车
   */
  async addCartFromGoodsItem() {
    // 1.判断用户是否登录
    const user = UserAuth.getInstance().getUser()
    if (!!user?.token) {
      // 2.判断商品规则选择是否完整
      if (!!this.sku.id) {
        try {
          // 3.调用接口发请求
          this.loading = true
          await addGoodsToCartApi({
            skuId: this.sku.id,
            count: String(this.counterNumber)
          })
          this.promptAction.showToast({ message: '添加成功' })
        } catch (error) {
          this.promptAction.showToast({ message: '加入失败' })
        } finally {
          this.loading = false
          this.showSheet = false
        }
      } else {
        this.promptAction.showToast({ message: '请完善商品规格后重新操作' })
      }
    } else {
      this.promptAction.showToast({ message: '请先登录' })
      this.showSheet = false
      HMRouterMgr.push({
        pageUrl: StackAddress.LOGIN_PAGE
      })
    }
  }

  build() {
    Column() {
      NavigationBar({
        title: '',
        showRightIcon: true,
        customTitle: (): void => this.CustomTitleBuilder(),
        onLeftClick: () => HMRouterMgr.pop()
      })
      Column() {
        List({ scroller: this.scroller }) {
          ListItem() {
            // 商品信息
            GoodsInformation({ goods: this.goods }).geometryTransition(this.goods.id)
          }

          ListItem() {
            // 评论 目前无评论数据
            GoodsComment({ goods: this.goods })
          }

          ListItem() {
            // 商品详情
            GoodsDetail({ goods: this.goods })
          }

          ListItem() {
            // 猜你喜欢
            GuessingComponent()
          }
        }
        .onScrollIndex((index) => {
          this.activeIndex = index
        })
        .scrollBar(BarState.Off)
        .width('100%')
        .height('100%')
      }
      .layoutWeight(1)
      .backgroundColor($r('app.color.under'))

      Row() {
        Image($r('app.media.ic_public_like'))
          .iconButton()
        Image($r('app.media.ic_public_comment'))
          .iconButton()
        Badge({
          count: 0,
          style: {},
          position: { x: 30, y: 4 }
        }) {
          Image($r('app.media.ic_public_cart'))
            .iconButton()
            .onClick(() => {

            })
        }

        Row() {
          Button('加入购物袋')
            .buyButton($r('app.color.black'), true)
            .onClick(() => {
              this.showSheet = true
            })
          Button('立即购买')
            .buyButton($r('app.color.red'), false)
            .onClick(async () => {})
        }
        .layoutWeight(1)
        .padding({ right: 16, left: 6 })
      }
      .height(54)
      .width('100%')
      .margin({ bottom: this.safeAreaValue?.topHeight })
    }
    .height('100%')
    .bindSheet($$this.showSheet, this.AddCartBuilder(),
      {
        height: SheetSize.FIT_CONTENT,
        backgroundColor: $r('app.color.white'),
        preferType: SheetType.CENTER
      }
    )
  }

  @Builder CustomTitleBuilder() {
    // 楼层切换
    Row() {
      Row({ space: 10 }) {
        ForEach(this.tabsList, (tabName: string, index: number) => {
          Text(tabName)
            .fontColor(this.activeIndex == index ? $r("app.color.black") : $r("app.color.gray"))
            .onClick(() => {
              this.activeIndex = index
              this.scroller.scrollToIndex(index)
            })
        })
      }
      Image($r('app.media.ic_public_shared')).iconButton()
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width("100%")
    .height("100%")
    .padding({
      left: 50,
      right: 50
    })

  }

  @Builder AddCartBuilder() {
    Column() {
      Text(`已选:${this.sku.specsText}`)
        .fontWeight(300)
        .width('100%')
        .fontColor($r('app.color.black'))
        .fontSize(14)
        .padding({ bottom: 10, right: 50 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .visibility(this.sku.id ? Visibility.Visible : Visibility.Hidden)
      Row({ space: 10 }) {
        Image(this.sku.picture || this.goods.mainPictures?.[0])
          .alt($r('app.media.ic_sku_img'))
          .width(80)
          .height(80)
          .backgroundColor($r('app.color.under'))
          .borderRadius(4)
        Column() {
          Row() {
            Text('现价¥')
              .fontSize(14)
              .fontColor($r('app.color.black'))
              .offset({ y: -4 })
            Text(this.sku.price || this.goods.price)
              .fontSize(24)
              .fontColor($r('app.color.black'))
              .fontWeight(500)
            Text('原价¥' + (this.sku.oldPrice || this.goods.price))
              .fontSize(12)
              .fontColor($r('app.color.gray'))
              .margin({ left: 10 })
              .offset({ y: -4 })
              .decoration({
                type: TextDecorationType.LineThrough,
                color: $r('app.color.gray')
              })
          }
          .alignItems(VerticalAlign.Bottom)

          Row({ space: 10 }) {
            // 计数器
            Counter(){
              Text(String(this.counterNumber))
            }.enableDec(this.counterNumber > 1) // 减法使用约束
            .onInc(() => this.counterNumber++)
            .onDec(() => this.counterNumber--)

            Text(this.goods.inventory > 10000 ? '库存充足' : '库存紧张')
              .fontSize(12)
              .fontColor(this.goods.inventory > 10000 ? $r('app.color.gray') : $r('app.color.red'))
          }
        }
        .height(80)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      Divider()
        .strokeWidth(4)
        .color($r('app.color.under'))
        .margin({ left: -8, right: -8, top: 13 })

      List() {
        ListItem() {
          // Sku 组件
          Sku({
            skus: this.goods.skus,
            specs: this.goods.specs,
            onSkuChange: (sku: SkuType) => {
              this.sku = sku
            }
          })
        }
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      Row() {
        Button(this.loading ? '加入中...' : '加入购物袋')
          .buyButton($r('app.color.black'), true)
          .onClick(() => {
            // 实现加入购物车
            this.addCartFromGoodsItem()
          })
        Button('立即购买')
          .buyButton($r('app.color.red'), false)
          .onClick(async () => {})
      }
      .width('100%')
    }
    .height(600)
    .padding({
      left: 16,
      right: 16,
      top: 16,
      bottom: this.safeAreaValue?.bottomHeight || 16
    })
  }
}

@Extend(Image) function iconButton() {
  .width(24)
  .aspectRatio(1)
  .margin(13)
  .fillColor($r('app.color.black'))
}

@Extend(Button) function buyButton(color: ResourceStr, isLeft: boolean) {
  .fontSize(14)
  .height(36)
  .type(ButtonType.Normal)
  .layoutWeight(1)
  .backgroundColor(color)
  .borderRadius({
    topLeft: isLeft ? 18 : 0,
    bottomLeft: isLeft ? 18 : 0,
    topRight: isLeft ? 0 : 18,
    bottomRight: isLeft ? 0 : 18
  })
  .pixelRound({
    end: PixelRoundCalcPolicy.FORCE_CEIL,
    start: PixelRoundCalcPolicy.FORCE_FLOOR
  })
}

