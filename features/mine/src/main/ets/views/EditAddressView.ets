import { AppSafeArea, ATManager, Logger, NavigationBar, StackAddress } from 'basic';
import { AppStorageV2, promptAction, UIUtils } from '@kit.ArkUI';
import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { AddAddressRequest, AddressForm } from '../models';
import { addAddressApi, updateAddressApi } from '../api';
import { geoLocationManager } from '@kit.LocationKit';
import { SuppressWarnings, SuppressWarningsType } from '@kit.BasicServicesKit';


@HMRouter({ pageUrl: StackAddress.EDIT_ADDRESS_PAGE })
@ComponentV2
export struct AddressCreateView {
  safeArea: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())!
  @Local addressData: AddressForm = new AddressForm({} as AddAddressRequest)
  @Local text: string = ""

  aboutToAppear(): void {
    const param = HMRouterMgr.getCurrentParam()
    if (param) {
      this.addressData = new AddressForm(param as AddAddressRequest)
    }
  }

  async getLocation() {
    // 1.检查权限
    ATManager.getInstance().mContext = this.getUIContext().getHostContext()
    const firstCheck = await ATManager.getInstance().getAccessFromUser(['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'])
    if (!firstCheck) {
      const secondCheck = await ATManager.getInstance().getAccessFromSetting(['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'])
      if (!secondCheck) {
        promptAction.openToast({ message: '要使用定位功能，请先允许定位权限' })
      }
    } else {
      promptAction.openToast({ message: '已经获取权限' })
      // 2.开始定位
      let requestInfo: geoLocationManager.CurrentLocationRequest = {
        'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
        'scenario': geoLocationManager.LocationRequestScenario.UNSET,
        'maxAccuracy': 0
      }
      const res = await geoLocationManager.getCurrentLocation(requestInfo)
      Logger.info(res)
      if (res) {
        const result = await geoLocationManager.getAddressesFromLocation(res)
        Logger.info(result)
        if (result[0].placeName) {
          return result[0].placeName
        }
      }
      return
    }
    return
  }

  async onSubmit() {
    if (!this.addressData.receiver && !this.addressData.contact && !this.addressData.address) {
      promptAction.openToast({ message: '表单内容必须填写完整' })
      return
    }
    if (this.addressData.id) {
      await updateAddressApi({
        id: this.addressData.id,
        contact: this.addressData.contact,
        isDefault: this.addressData.isDefault,
        receiver: this.addressData.receiver,
        address: this.addressData.address
      } as AddAddressRequest)
    } else {
      await addAddressApi({
        contact: this.addressData.contact,
        isDefault: this.addressData.isDefault,
        receiver: this.addressData.receiver,
        address: this.addressData.address
      } as AddAddressRequest)
    }
    promptAction.openToast({ message: '操作地址成功' })
    HMRouterMgr.pop()
  }

  build() {
    Column() {
      // 顶部区域
      NavigationBar({
        title: this.addressData.id ? '编辑地址' : '新增地址',
        onLeftClick: () => HMRouterMgr.pop()
      })
      // 地址信息表单
      Row() {
        List() {
          ListItem() {
            Row() {
              Text('收货人')
                .width(80)
                .fontSize(14)
                .fontColor($r('app.color.black'))
              TextInput({ placeholder: '请填写收货人名称', text: this.addressData.receiver!! })
                .fontSize(14)
                .backgroundColor($r('app.color.white'))
            }
            .padding({ top: 4, bottom: 4 })
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .backgroundColor($r('app.color.white'))
          }

          ListItem() {
            Row() {
              Text('手机号码')
                .width(80)
                .fontSize(14)
                .fontColor($r('app.color.black'))
              TextInput({ placeholder: '请填写收货人电话', text: this.addressData.contact!! })
                .fontSize(14)
                .backgroundColor($r('app.color.white'))

            }
            .padding({ top: 4, bottom: 4 })
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .backgroundColor($r('app.color.white'))
          }

          ListItem() {
            Row() {
              Text('详细地址')
                .width(80)
                .fontSize(14)
                .fontColor($r('app.color.black'))
              TextInput({ placeholder: '请填写详细地址', text: this.addressData.address!! })
                .fontSize(14)
                .backgroundColor($r('app.color.white'))
                .layoutWeight(1)
              Image($r('sys.media.ohos_ic_public_location'))
                .width(24)
                .height(24)
                .fillColor($r('app.color.black'))
                .onClick(async () => {
                  const res = await this.getLocation()
                  if (res) {
                    Logger.info( res)
                    this.addressData.address = res
                  }
                })
            }
            .padding({ top: 4, bottom: 4 })
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .backgroundColor($r('app.color.white'))
          }

          ListItem() {
            Row() {
              Text('设为默认地址')
                .fontSize(14)
                .fontColor(($r('app.color.black')))
              Toggle({ isOn: this.addressData.isDefault === 0 ? true : false, type: ToggleType.Checkbox })
                .selectedColor(($r('app.color.red')))
                .onChange((isOn) => {
                  this.addressData.isDefault = isOn ? 0 : 1
                })
            }
            .padding({ top: 4, bottom: 4 })
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .backgroundColor($r('app.color.white'))
          }
        }
        .width('100%')
        .height('100%')
        .divider({
          strokeWidth: 1,
          color: '#eee'
        })
        .padding({ left: 8, right: 8 })
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Top)


      // 底部保存按钮
      Row() {
        Button('保存')
          .backgroundColor(($r('app.color.black')))
          .fontSize(14)
          .width('100%')
          .onClick(() => {
            this.onSubmit()
          })
      }
      .height(46)
      .padding({ left: 16, right: 16 })
    }
    .height('100%')
    .backgroundColor('#F5F4F9')
    .padding({
      bottom: this.safeArea.bottomHeight,
      // top: this.safeArea.topHeight
    })

  }
}
