import { AppSafeArea, NavigationBar, StackAddress } from 'basic'
import { AppStorageV2, promptAction } from '@kit.ArkUI'
import { HMLifecycleState, HMRouter, HMRouterMgr } from '@hadss/hmrouter'
import { AddressResponse } from '../models'
import { getAddressListApi } from '../api'

@HMRouter({ pageUrl: StackAddress.ADDRESS_PAGE })
@ComponentV2
export struct AddressView {
  @Local addressList: AddressResponse[] = []
  safeArea: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())!

  // 获取地址列表
  async getAddressList() {
    this.addressList = await getAddressListApi()

    // 页面已进入可交互状态，相当于 onPageShow
    HMRouterMgr.getCurrentLifecycleOwner()?.addObserver(HMLifecycleState.onShown, () => {
      this.getAddressList()
    })

    HMRouterMgr.getCurrentLifecycleOwner()?.addObserver(HMLifecycleState.onHidden, () => {
    })
  }

  aboutToAppear(): void {
    this.getAddressList()
  }

  build() {
    Column() {
      NavigationBar({
        title: "收货地址管理"
      })

      Row() {
        List() {
          ForEach(this.addressList, (item: AddressResponse) => {
              ListItem() {
                Row() {
                  Column() {
                    Row() {
                      // 是否默认
                      if (item.isDefault == 0) {
                        Row() {
                          Text('默认')
                            .fontSize(13)
                            .fontColor($r('app.color.white'))
                        }
                        .borderRadius(2)
                        .padding({
                          left: 8,
                          right: 8,
                          top: 2,
                          bottom: 2
                        })
                        .linearGradient({
                          angle: '93',
                          colors: [
                            ['#FD3F8F', 0], ['#FF773C', 1]
                          ]
                        })
                        .margin({
                          right: 4
                        })
                      }

                      Text(item.address)
                        .fontColor('#434343')
                        .fontSize(14)

                    }

                    Text(`${item.receiver} ${item.contact}`)
                      .margin({ top: 8 })
                      .fontSize(12)
                  }
                  .alignItems(HorizontalAlign.Start)

                  Row() {
                    Image($r("app.media.ic_public_edit"))
                      .width(16)
                      .onClick(() => {
                        HMRouterMgr.push({
                          pageUrl: StackAddress.EDIT_ADDRESS_PAGE,
                          param: item
                        })
                      })
                  }
                }
                .padding(16)
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                .backgroundColor($r('app.color.white'))
              }
              .margin({ bottom: 10 })
              .swipeAction({
                end: this.ActionBuilder(item.id)
              })
            }
          )
        }
        .width('100%')
        .height('100%')
      }
      .margin({ top: 8 })
      .padding({ left: 8, right: 8 })
      .layoutWeight(1)
      .alignItems(VerticalAlign.Top)

      // 底部新增地址
      Row() {
        Button('新增地址')
          .backgroundColor($r('app.color.black'))
          .fontSize(14)
          .width('100%')
          .onClick(() => HMRouterMgr.push({
            pageUrl: StackAddress.EDIT_ADDRESS_PAGE
          }))
      }
      .height(46)
      .padding({ left: 16, right: 16, })
    }
    .height('100%')
    .backgroundColor('#F5F4F9')
    .padding({
      bottom: this.safeArea.bottomHeight,
      // top: this.safeArea.topHeight
    })
  }

  @Builder ActionBuilder(id: string) {
    Row() {
      Row() {
        Text('设为默认')
          .fontColor($r('app.color.white'))
          .fontSize(11)
          .padding({ left: 10, right: 10 })
      }
      .layoutWeight(1)
      .height('100%')
      .backgroundColor($r('app.color.black'))
      .onClick(async () => {})

      Row() {
        Text('删除')
          .fontColor($r('app.color.white'))
          .fontSize(11)
          .padding({ left: 10, right: 10 })
      }
      .backgroundColor($r('app.color.red'))
      .layoutWeight(1)
      .height('100%')
      .onClick(async () => {})
    }
    .width(88)
  }
}