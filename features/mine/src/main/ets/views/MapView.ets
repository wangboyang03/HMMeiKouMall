import { HMLifecycleState, HMRouter, HMRouterMgr } from '@hadss/hmrouter'
import { AppSafeArea, NavigationBar, StackAddress } from 'basic'
import { AppStorageV2 } from '@kit.ArkUI'
import mapCommon from '@hms.core.map.mapCommon'
import { map, MapComponent } from '@kit.MapKit'
import { AsyncCallback } from '@kit.BasicServicesKit'


@HMRouter({ pageUrl: StackAddress.MAP_PAGE })
@ComponentV2
export struct SetMapView {
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  mapOptions?: mapCommon.MapOptions
  mapController?: map.MapComponentController
  mapCallBack?: AsyncCallback<map.MapComponentController>
  mapEventManager?: map.MapEventManager

  aboutToAppear(): void {
    this.mapOptions = {
      position: {
        target: {
          latitude: 39.9082, // 纬度
          longitude: 116.294275 // 精度
        },
        zoom: 20
      }
    }

    // 地图回调
    this.mapCallBack = async (error, mapController) => {
      if (!error) {
        this.mapController = mapController
        this.mapEventManager = this.mapController.getEventManager()
      }
    }

    // 生命周期监听
    HMRouterMgr.getCurrentLifecycleOwner()?.addObserver(HMLifecycleState.onShown, () => {
      if (!!this.mapController) {
        this.mapController.show()
      }
    })
    HMRouterMgr.getCurrentLifecycleOwner()?.addObserver(HMLifecycleState.onHidden, () => {
      if (!!this.mapController) {
        this.mapController.hide()
      }
    })
  }

  build() {
    Column() {
      NavigationBar({
        title: '地图',
        showLeftIcon: true,
        onLeftClick: () => HMRouterMgr.pop()
      })
      // TODO
      MapComponent({
        mapOptions: this.mapOptions,
        mapCallback: this.mapCallBack
      })
        .width('100%')
        .height('100%')
    }
    .width('100%')
    .height('100%')
    .padding({ bottom: this.safeAreaValue?.bottomHeight })
    .backgroundColor($r('app.color.under'))
  }
}