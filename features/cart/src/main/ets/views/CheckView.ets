import { AppSafeArea, OrderGoodsItem, StackAddress, UserAddress, Summary, NavigationBar, Cell, NetworkRequestUtil, Constants, PreOrder,
  CreateOrderParams,
  CreateOrderResult,
  CartManager} from 'basic'
import { AppStorageV2 } from '@kit.ArkUI'
import { HMRouter, HMRouterMgr } from '@hadss/hmrouter'



@HMRouter({ pageUrl: StackAddress.CHECK_PAGE })
@ComponentV2
export struct CheckView {
  safeArea: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())!
  // 商品列表
  @Local goodsList: OrderGoodsItem[] = []
  // 地址
  @Local addressList: UserAddress[] = []
  // 摘要
  @Local summary: Summary = {} as Summary
  // 弹框
  @Local showPaySheet: boolean = false
  // 支付渠道
  @Local payChannel: number = 1
  // 地址 id
  @Local addressId: string = ''
  // 是否 loading
  @Local loading: boolean = false

  async submitOrder() {
    if (this.payChannel !== 1) {
      return this.getUIContext().getPromptAction().showToast({ message: '暂不支持该支付方式' })
    }
    if (!this.addressId) {
      return this.getUIContext().getPromptAction().showToast({ message: '未选择收货地址' })
    }
    this.loading = true
    // 调用创建订单接口
    const memberOrderAPI = (data: CreateOrderParams) => NetworkRequestUtil.post<CreateOrderResult>(Constants.MEMBER_ORDER_API, data)
    const res = await memberOrderAPI({
      deliveryTimeType: 1,
      payType: 1,
      buyerMessage: "",
      payChannel: 1,
      goods: this.goodsList,
      addressId: this.addressId
    })
    this.getUIContext().getPromptAction().showDialog({message: res.id}) // 拿到订单id
    CartManager.getInstance().updateCartCount() // 更新购物车
  }

  @Builder
  GoodsItemBuilder(goods: OrderGoodsItem) {
    Row({ space: 10 }) {
      Image(goods.picture)
        .width(80)
        .height(80)
      Column({ space: 8 }) {
        Text(goods.name)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .fontSize(14)
          .fontColor($r('app.color.black'))
          .width('100%')
        Row({ space: 8 }) {
          Text(goods.attrsText)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .fontSize(12)
            .fontColor($r('app.color.text'))
            .layoutWeight(1)
          Text('x' + goods.count)
            .fontSize(14)
            .fontColor($r('app.color.gray'))
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Text('¥' + goods.payPrice)
          .width('100%')
          .fontSize(16)
          .fontColor($r('app.color.black'))
      }
      .layoutWeight(1)
    }
    .padding({ top: 10, bottom: 10 })
    .border({
      width: { bottom: 0.5 },
      color: '#e4e4e4'
    })
  }

  payChannels = ['支付宝', '微信支付', '华为支付']

  // 半模态
  @Builder
  PaySheetBuilder() {
    Column() {
      Text('¥' + this.summary.totalPayPrice?.toString())
        .fontSize(20)
        .fontWeight(500)
        .fontColor($r('app.color.black'))
        .height(50)
        .width('100%')
        .border({
          width: { bottom: 0.5 },
          color: $r('app.color.under')
        })
      ForEach(this.payChannels, (label: string, index) => {
        CheckCell({
          label: label, checked: this.payChannel === index + 1, onClickBox: () => {
            this.payChannel = index + 1
          }
        })
          .onClick(() => {
            this.payChannel = index + 1
          })
      })
      Row() {
        Button(this.loading ? '提交中...' : '立即支付')
          .width('100%')
          .height(36)
          .fontSize(14)
          .backgroundColor($r('app.color.red'))
          .onClick(() => {
            this.submitOrder()
          })
      }
      .height(50)
    }
    .padding({ left: 16, right: 16, bottom: this.safeArea.bottomHeight })
  }

  aboutToAppear(): void {
    this.getPreOrder()
  }

  async getPreOrder() {
    const result = await NetworkRequestUtil.get<PreOrder>(Constants.PRE_ORDER_API)
    this.goodsList = result.goods
    this.addressList = result.userAddresses
    this.summary = result.summary
  }

  build() {
    // NavDestination() {
    Column() {
      NavigationBar({
        title: '结算', onLeftClick: () => HMRouterMgr.pop()
      })
        .border({
          width: { bottom: 0.5 },
          color: '#e4e4e4'
        })
      List() {
        ListItem() {
          ChangeAddressComponent({
            addressList: this.addressList, onChangeAddress: (addr) => {
              this.addressId = addr?.id
            }
          })
        }

        ListItem() {
          Row() {
            Column() {
              ForEach(this.goodsList, (goods: OrderGoodsItem) => {
                this.GoodsItemBuilder(goods)
              })
            }
            .padding({ left: 8, right: 8 })
            .backgroundColor($r('app.color.white'))
          }
          .padding({ top: 8, left: 8, right: 8 })
        }

        ListItem() {
          Row() {
            Column() {
              Cell({ title: '配送时间', value: '时间不限' })
              Cell({ title: '留言', value: '建议留言前先和卖家沟通' })
            }
            .padding({ left: 8, right: 8 })
            .backgroundColor($r('app.color.white'))
          }
          .padding({ top: 8, left: 8, right: 8 })
        }

        ListItem() {
          Row() {
            Column() {
              PriceCell({ label: '商品总价', price: this.summary.totalPrice })
              PriceCell({ label: '运费', price: this.summary.postFee })
              PriceCell({ label: '实付金额', price: this.summary.totalPayPrice, isRed: true })
            }
            .padding({ left: 8, right: 8 })
            .backgroundColor($r('app.color.white'))
          }
          .padding({ top: 8, left: 8, right: 8 })
        }

        ListItem() {
          Row() {
            Column() {
              CheckCell({ label: '在线支付', checked: true })
              CheckCell({ label: '货到付款' })
            }
            .padding({ left: 8, right: 8 })
            .backgroundColor($r('app.color.white'))
          }
          .padding(8)
        }

      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      Row() {
        Column() {
          Text() {
            Span('¥')
              .fontSize(14)
            Span(this.summary.totalPayPrice?.toFixed(2))
              .fontSize(20)
          }
          .fontColor($r('app.color.red'))
          .fontWeight(500)

          Text() {
            Span('共减')
              .fontColor($r('app.color.gray'))
            Span('¥00.00')
              .fontColor($r('app.color.red'))
              .fontWeight(500)
          }
          .fontSize(8)
        }
        .alignItems(HorizontalAlign.Start)

        Blank()
        Button('提交订单')
          .fontSize(14)
          .height(36)
          .backgroundColor($r('app.color.red'))
          .onClick(() => {
            this.showPaySheet = true
          })
      }
      .height(50 + this.safeArea.bottomHeight)
      .width('100%')
      .backgroundColor($r('app.color.white'))
      .border({
        width: { top: 0.5 },
        color: '#e4e4e4'
      })
      .padding({ left: 16, right: 16, bottom: this.safeArea.bottomHeight })
    }
    .backgroundColor($r('app.color.under'))
    .bindSheet($$this.showPaySheet, this.PaySheetBuilder(), {
      title: {
        title: '支付方式',
        subtitle: '请选择一种支付方式进行付款'
      }, height: SheetSize.FIT_CONTENT, backgroundColor: $r('app.color.white')
    })

  }
}

@ComponentV2
struct ChangeAddressComponent {
  @Param addressList: UserAddress[] = []
  @Local currentAddress: UserAddress = {} as UserAddress
  @Event
  onChangeAddress: (address: UserAddress) => void = () => {}

  @Monitor("addressList")
  onAddressListChange() {
    const defAddress = this.addressList.find(addr => addr.isDefault === 0)
    if (defAddress) {
      this.currentAddress = defAddress
    } else {
      this.currentAddress = this.addressList[0]
    }
    this.onChangeAddress(this.currentAddress)
  }

  aboutToAppear() {
    this.onChangeAddress(this.currentAddress)
  }

  @Builder
  AddressTipBuilder() {
    if (this.addressList.length) {
      Column({ space: 8 }) {
        Row({ space: 4 }) {
          if (this.currentAddress.isDefault === 0) {
            Text('默认')
              .fontSize(14)
              .width(40)
              .height(20)
              .borderRadius(4)
              .fontColor($r('app.color.white'))
              .textAlign(TextAlign.Center)
              .linearGradient({
                angle: 90,
                colors: [[$r('app.color.linear_begin'), 0], [$r('app.color.linear_end'), 1]]
              })
          }
          Text(this.currentAddress.fullLocation)
            .fontSize(14)
            .fontColor($r('app.color.text'))
        }

        Text(this.currentAddress.address)
          .fontWeight(500)
          .fontSize(16)
          .fontColor($r('app.color.black'))
        Text(`${this.currentAddress.receiver} ${this.currentAddress.contact}`)
          .fontSize(13)
          .fontColor($r('app.color.text'))
      }
      .alignItems(HorizontalAlign.Start)
      .padding({ top: 10, bottom: 10 })
    } else {
      Text('请填写收货地址')
        .fontSize(14)
        .fontColor($r('app.color.gray'))
    }
  }

  build() {
    Row() {
      Cell({
        customLabel: () => {
          this.AddressTipBuilder()
        }
      })
    }
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('app.color.white'))
    .width('100%')
    .onAppear(() => {
      this.onChangeAddress(this.currentAddress)
    })
  }
}

@ComponentV2
struct PriceCell {
  @Param label: string = ""
  @Param price: number = 0
  @Param isRed: boolean = false

  @Builder
  PriceBuilder() {
    Text('¥' + this.price)
      .fontSize(this.isRed ? 16 : 14)
      .fontColor(this.isRed ? $r('app.color.red') : $r('app.color.gray'))
  }

  build() {
    Cell({
      title: this.label, customIcon: () => {
        this.PriceBuilder()
      }
    })
  }
}

@Component
struct CheckCell {
  @Prop label: string
  @Prop checked: boolean = false
  onClickBox: () => void = () => {

  }

  @Builder
  CheckBuilder() {
    Checkbox()
      .selectedColor($r('app.color.red'))
      .select(this.checked)
      .onClick(() => {
        this.onClickBox()
      })
  }

  build() {
    Cell({
      title: this.label, customIcon: () => {
        this.CheckBuilder()
      }
    })
  }
}