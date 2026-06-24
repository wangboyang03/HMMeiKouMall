import { HMLifecycleState, HMRouter, HMRouterMgr } from '@hadss/hmrouter'
import { AppSafeArea, ATManager, NavigationBar, StackAddress } from 'basic'
import { AppStorageV2 } from '@kit.ArkUI'
import mapCommon from '@hms.core.map.mapCommon'
import { map, MapComponent } from '@kit.MapKit'
import { AsyncCallback } from '@kit.BasicServicesKit'
import { geoLocationManager } from '@kit.LocationKit'


@HMRouter({ pageUrl: StackAddress.MAP_PAGE })
@ComponentV2
export struct SetMapView {
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  mapOptions?: mapCommon.MapOptions
  mapController?: map.MapComponentController
  mapCallBack?: AsyncCallback<map.MapComponentController>
  mapEventManager?: map.MapEventManager
  marker?: map.Marker

  async aboutToAppear(): Promise<void> {
    // 1. 设置地图参数
    this.mapOptions = {
      position: {
        target: {
          latitude: 39.90923, // 纬度
          longitude: 116.294275 // 精度
        },
        zoom: 18,
      }
    }

    // 2. 设置地图回调
    this.mapCallBack = async (error, mapController) => {
      if (!error) {
        this.mapController = mapController
        this.mapController?.setBuildingEnabled(true)
        this.mapEventManager = this.mapController?.getEventManager()
        let callback = async () => {
          // 申请位置权限
          const res = await ATManager.getInstance().checkPermissions(["ohos.permission.LOCATION", "ohos.permission.APPROXIMATELY_LOCATION"])
          if (!res) {
            HMRouterMgr.pop()
          }
          if (res) {
            this.mapController?.setMyLocationEnabled(true)
            this.mapController?.setMyLocationControlsEnabled(true)
          }
          // 绘制摇杆
          let markerOptions: mapCommon.MarkerOptions = {
            position: {
              latitude: 39.90923,
              longitude: 116.294275
            },
            rotation: 0,
            visible: true,
            zIndex: 0,
            alpha: 1,
            anchorU: 0.5,
            anchorV: 1,
            clickable: true,
            draggable: true,
            flat: false,
            icon: $r('sys.media.huawei_id_logo_red')
          }
          this.marker = await this.mapController?.addMarker(markerOptions)
        }
        this.mapEventManager.on('mapLoad', callback)
      }
    }

    // 3. 路由生命周期监听
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

    // 4.通过获取经纬度拿到当前地址
    const location = await geoLocationManager.getCurrentLocation()
    const requestFromLocation: geoLocationManager.ReverseGeoCodeRequest = {
      latitude: location.latitude,
      longitude: location.longitude,
      maxItems: 1
    }
    const address = await geoLocationManager.getAddressesFromLocation(requestFromLocation)
    this.getUIContext().getPromptAction().openToast({
      message: address[0].placeName
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
    .height('90%')
    .padding({ bottom: this.safeAreaValue?.bottomHeight })
    .backgroundColor($r('app.color.under'))
  }
}