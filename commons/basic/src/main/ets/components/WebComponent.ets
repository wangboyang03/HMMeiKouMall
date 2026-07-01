import { AppSafeArea, LoginResponseViewModel } from "../models"
import { AppStorageV2 } from "@kit.ArkUI"
import { webview } from "@kit.ArkWeb"
import { HMRouterMgr } from "@hadss/hmrouter"
import { emitter } from "@kit.BasicServicesKit"
import { Constants } from "../Constants"
import { Logger } from "../utils/Logger"
import { UserAuth } from "../utils/UserAuth"
import { camera, cameraPicker } from "@kit.CameraKit"
import { fileIo } from "@kit.CoreFileKit"
import { photoAccessHelper } from "@kit.MediaLibraryKit"
import { util } from "@kit.ArkTS"
import { LocationData, LocationPlugin } from "../utils"

@Component
export struct WebComponent {
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  @Prop title: string = ""
  @Prop src: ResourceStr = "m.suning.com"
  @State isLoading: boolean = false
  @State progress: number = 0
  controller: webview.WebviewController = new webview.WebviewController()
  @State historyCurrIndex: number = 0
  @State historySize: number = 0

  build() {
    Column() {
      this.NavigationBar()

      Stack({
        alignContent: Alignment.Top
      }) {
        if (this.isLoading) {
          // 进度条
          Progress({
            value: this.progress,
            total: 100,
            type: ProgressType.Linear,
          })
            .style({
              strokeWidth: 2,
              enableSmoothEffect: true
            })
            .color($r('app.color.red'))
            .zIndex(1)
        }
        Web({
          controller: this.controller,
          src: this.src
        })
          .onPageBegin(() => {
            this.progress = 0
            this.isLoading = true
          })
          .onProgressChange((data: OnProgressChangeEvent) => {
            if (!!data) {
              this.progress = data.newProgress
              this.getUIContext().animateTo({
                duration: 300,
                delay: 300
              }, () => this.isLoading = data.newProgress == 100 ? false : true)
            }
          })
          // 加载网页页面完成时触发该回调，用于应用更新其访问的历史链接
          .onRefreshAccessedHistory(() => {
            const history = this.controller.getBackForwardEntries()  // 获取当前Webview的历史信息列表
            this.historyCurrIndex = history.currentIndex  // 当前在页面历史列表中的索引
            this.historySize = history.size  // 历史列表中索引的数量，最多保存50条，超过时起始记录会被覆盖
          })
          .onTitleReceive((data: OnTitleReceiveEvent) => this.title = data?.title ?? "H5网页") // 获取网页标题给导航栏标题
          .onAppear(() => {
            try {
              this.controller.registerJavaScriptProxy({
                // 查询用户信息
                queryUser: (): LoginResponseViewModel => UserAuth.getInstance().getUser(),
                // 设置用户信息
                setUser: (data: LoginResponseViewModel): void => UserAuth.getInstance().setUser(data),
                // 移除用户
                removeUser: (): void => UserAuth.getInstance().setUser({} as LoginResponseViewModel),
                // 拉起相机拍照
                pickerCamera: async () => {
                  try {
                    // 打开相机 获取base64编码
                    const picker: cameraPicker.PickerProfile = {
                      cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
                    }
                    const pickerResult: cameraPicker.PickerResult = await cameraPicker.pick(this.getUIContext().getHostContext(), [cameraPicker.PickerMediaType.PHOTO], picker)
                    // Logger.info(pickerResult.resultUri)
                    const file = fileIo.openSync(pickerResult.resultUri, fileIo.OpenMode.READ_ONLY) // 打开文件
                    const arrayBuffer = new ArrayBuffer(fileIo.statSync(file.fd).size) // 创建buffer缓存对象
                    fileIo.readSync(file.fd, arrayBuffer) // 读取文件
                    fileIo.closeSync(file) // 关闭文件
                    const base64 = new util.Base64Helper()
                    const string = base64.encodeToStringSync(new Uint8Array(arrayBuffer))
                    return string
                  } catch (error) {
                    return ""
                  }
                },
                // 拉起相册
                pickerPhoto: async () => {
                  try {
                    // 打开相册选择图片
                    const selectedOption = new photoAccessHelper.PhotoSelectOptions() // 创建选择图片的参数对象
                    selectedOption.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE // 选择图片类型的媒体
                    selectedOption.maxSelectNumber = 1 // 约束最大的选择次数
                    const photoPicker = new photoAccessHelper.PhotoViewPicker() // 创建图片选择器
                    const selectedResult = await photoPicker.select(selectedOption) // 选择图片

                    // 获取图片的base64编码
                    const file = fileIo.openSync(selectedResult.photoUris[0], fileIo.OpenMode.READ_ONLY) // 打开文件
                    const arrayBuffer = new ArrayBuffer(fileIo.statSync(file.fd).size) // 创建buffer缓存对象
                    fileIo.readSync(file.fd, arrayBuffer) // 读取文件
                    fileIo.closeSync(file) // 关闭文件
                    const base64 = new util.Base64Helper()
                    const string = base64.encodeToStringSync(new Uint8Array(arrayBuffer))
                    return string
                  } catch (error) {
                    return ""
                  }
                },
                // 获取省市区
                getAreaColumns: (): Promise<LocationData> => LocationPlugin.getInstance().getLocationData(this.getUIContext().getHostContext()), // 获取省市区
              },
                "meikouProxy",
                [
                  "queryUser", "setUser", "removeUser", "pickerCamera", "pickerPhoto", "getAreaColumns"
                ])
            } catch (error) {
              Logger.error("onAppear", error)
            }
          })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.under'))
  }

  @Builder NavigationBar() {
    Column(){
      if (!!this.safeAreaValue) {
        // 导航条
        Row() {
          Row() {
            Image($r("app.media.ic_public_left"))
              .iconStyle()
              .onClick(() => {
                // back
                if (this.historyCurrIndex > 0) {
                  this.controller.backward()
                } else {
                  HMRouterMgr.pop()
                }
              })
            Image($r('app.media.ic_public_close'))
              .iconStyle()
              .onClick(() => {
                HMRouterMgr.pop()
              })
          }
          .width(100)

          Text(this.title)
            .fontSize(16)
            .fontWeight(500)
            .fontColor($r('app.color.black'))
            .layoutWeight(1)
            .maxLines(1)
            .textAlign(TextAlign.Center)
            .textOverflow({ overflow: TextOverflow.MARQUEE })
          Row() {
            Blank()
            Image($r('app.media.ic_public_more'))
              .iconStyle()
              .bindMenu(this.MenuBuilder)
          }
          .width(100)
        }
        .height(50 + this.safeAreaValue.topHeight)
        .backgroundColor($r('app.color.white'))
        .padding({ top: this.safeAreaValue.topHeight })
      }
    }
    .width('100%')
    .backgroundColor($r('app.color.under'))
  }

  @Builder MenuBuilder() {
    Menu() {
      MenuItem({ content: '首页' })
        .onClick(() => {
          HMRouterMgr.removeAll()
          emitter.emit(Constants.SWITCH_HOMEPAGE, {
            data: {
              index: 0
            }
          })
        })
      MenuItem({ content: '分类' })
        .onClick(() => {
          HMRouterMgr.removeAll()
          emitter.emit(Constants.SWITCH_HOMEPAGE, {
            data: {
              index: 1
            }
          })
        })
      MenuItem({ content: '购物袋' })
        .onClick(() => {
          HMRouterMgr.removeAll()
          emitter.emit(Constants.SWITCH_HOMEPAGE, {
            data: {
              index: 3
            }
          })
        })
      MenuItem({ content: '我的' })
        .onClick(() => {
          HMRouterMgr.removeAll()
          emitter.emit(Constants.SWITCH_HOMEPAGE, {
            data: {
              index: 4
            }
          })
        })
      MenuItem({ content: '刷新一下' })
        .onClick(() => this.controller.refresh())
    }
    .width(100)
    .fontColor($r('app.color.text'))
    .font({ size: 14 })
    .radius(4)
  }

}

@Extend(Image) function iconStyle() {
  .width(24)
  .aspectRatio(1)
  .fillColor($r('app.color.text'))
  .margin(13)
}