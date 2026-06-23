import { HMRouter, HMRouterMgr } from "@hadss/hmrouter"
import { AppSafeArea, Constants, NavigationBar, NetworkRequestUtil, OrderItem, OrderListRequest, OrderListResponse, OrderSku, StackAddress } from "basic"
import { TabsContainer } from "../components"
import { AppStorageV2 } from "@kit.ArkUI"
import { EmptyComponent } from "cart"

@HMRouter({ pageUrl: StackAddress.ORDER_PAGE })
@Component
export struct OrderView {
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  @State activeIndex: number = 0
  @State list: OrderItem[] = []
  @State isEmpty: boolean = false
  @State page: string = '1'
  @State totalPage: number = 1

  @State isLoading: boolean = false
  @State isFinished: boolean = false

  async getOrderListData() {
    this.isLoading = true
    const memberOrderAPI = (params: OrderListRequest) => NetworkRequestUtil.get<OrderListResponse>(Constants.MEMBER_ORDER_API, params)
    const res = await memberOrderAPI({
      page: this.page,
      pageSize: '10',
      orderState: String(this.activeIndex)
    })
    // this.getUIContext().getPromptAction().showDialog({
    //   message: JSON.stringify(res)
    // })
    this.totalPage = res.pages
    this.list = this.list.concat(res.items)
    let page = Number(this.page)
    if (this.totalPage > page) {
      page++
    } else {
      this.isFinished = true
    }
    this.isLoading = false
  }

  async aboutToAppear(): Promise<void> {
    // 解析路由参数
    this.activeIndex = HMRouterMgr.getCurrentParam() as number
    this.getOrderListData()
  }

  build() {
    Column() {
      NavigationBar({
        title: "我的订单",
        showLeftIcon: true,
        onLeftClick: () => HMRouterMgr.pop()
      })

      // Tabs切换区域
      Row() {
        TabsContainer({
          activeIndex: this.activeIndex,
          onTabChange: (index: number) => {
            this.activeIndex = index
            this.page = '1'
            this.list = []
            this.getOrderListData()
          }
        })
      }
      .height(40)


      // 订单列表区域
      if (this.isEmpty) {
        EmptyComponent({
          onBtnClick: () => HMRouterMgr.pop()
        })
      } else {
        if (this.safeAreaValue) {
          List() {
            ForEach(this.list, (item: OrderItem, _) => {
              ListItem() {
                // 每一项订单
                Row() {
                  Column() {
                    // 左上角 日期 yyyy-mm-dd hh:mm:ss
                    Row() {
                      Text(item.createTime)
                        .fontSize(12)
                        .fontColor($r('app.color.gray'))
                      
                      // 根据状态判断渲染列表项
                      if (item.orderState == 1) {
                        Text('待付款').textStyles()
                      } else if (item.orderState == 2) {
                        Text('待发货').textStyles()
                      } else if (item.orderState == 3) {
                        Text('待收货').textStyles()
                      } else if (item.orderState == 4) {
                        Text('待评价').textStyles()
                      } else if (item.orderState == 5) {
                        Text('已完成').textStyles()
                      } else if (item.orderState == 6) {
                        Text('已取消').textStyles()
                      }
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.SpaceBetween)

                    // 商品项
                    ForEach(item.skus, (sku: OrderSku) => {
                      Row({ space: 10 }) {
                        Image(sku.image)
                          .width(80)
                          .aspectRatio(1)
                        Column({ space: 10 }) {
                          Text(sku.name)
                            .fontColor('#121826')
                            .fontSize(12)
                            .width('100%')
                          Text(sku.attrsText)
                            .width('100%')
                            .fontColor($r('app.color.text'))
                            .fontSize(12)
                            .lineHeight(20)
                            .fontWeight(FontWeight.Lighter)
                        }
                        .justifyContent(FlexAlign.Start)
                        .layoutWeight(1)
                        .height(80)

                        Column({ space: 10 }) {
                          Text('金额¥' + sku.curPrice)
                            .fontSize(12)
                            .fontColor('#191919')
                          Text('数量：' + sku.quantity)
                            .fontSize(12)
                            .fontColor('#A6A3AD')
                        }
                        .justifyContent(FlexAlign.Start)
                        .alignItems(HorizontalAlign.End)
                        .width(70)
                        .height(80)
                      }
                      .padding({ top: 10, bottom: 10 })
                    })

                    Text('实付款：¥' + item.payMoney)
                      .fontSize(14)
                      .fontWeight(FontWeight.Regular)
                      .fontColor('#191919')
                      .alignSelf(ItemAlign.End)
                      .padding({ bottom: 10 })

                    Row() {
                      // 1为待付款、2为待发货、3为待收货、4为待评价、5为已完成、6为已取消
                      if (item.orderState == 1) {
                        Button('立刻付款')
                          .enableClick()
                          .onClick(() => {})
                      } else if (item.orderState == 2) {
                        Button('取消订单')
                          .unEnableClick()
                          .onClick(() => {})
                      }
                      else if (item.orderState == 3) {
                        Button('再次购买')
                          .enableClick()
                          .onClick(() => {})
                      } else if (item.orderState == 4) {
                        Button('查看评价')
                          .unEnableClick()
                          .onClick(() => {})
                      } else if (item.orderState == 5) {
                        Button('查看评价')
                          .unEnableClick()
                          .onClick(() => {})
                      } else if (item.orderState == 6) {
                        Button('删除订单')
                          .unEnableClick()
                        .onClick(() => {})
                      }
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.End)
                  }
                  .padding(10)
                  .backgroundColor($r('app.color.white'))
                }
                .padding({ top: 6, left: 8, right: 8 })
              }
            })
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.None)
          .layoutWeight(1)
          .onReachEnd(async ()=> {
            if (!this.isLoading && !this.isFinished) {
              this.getOrderListData()
            }
          })
        }
      }
    }
    .backgroundColor($r('app.color.under'))
    .padding({ bottom: this.safeAreaValue?.bottomHeight })
    .height('100%')
  }
}

@Extend(Text) function textStyles() {
  .fontSize(12)
  .fontColor($r('app.color.red'))
}

@Extend(Button) function enableClick() {
  .height(30)
  .fontWeight(FontWeight.Normal)
  .fontSize(15)
  .padding({
    left: 10,
    right: 10,
  })
  .backgroundColor($r('app.color.red'))
}

@Extend(Button) function unEnableClick() {
  .fontColor($r('app.color.black'))
  .height(30)
  .fontWeight(FontWeight.Normal)
  .fontSize(15)
  .padding({
    left: 10,
    right: 10,
  })
  .border({
    width: 1,
    color: '#F5F4F9',
  })
  .backgroundColor($r('app.color.white'))
}