import { HMRouter, HMRouterMgr } from '@hadss/hmrouter'
import { AppSafeArea, AppUserObject,
  CartManager,
  HuaweiLoginAuth,
  LoginResponseViewModel, NavigationBar, StackAddress, UserAuth } from 'basic'
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI'
import { CellGroup, Cell } from '../components'

@HMRouter({ pageUrl: StackAddress.SETTING_PAGE })
@ComponentV2
export struct SettingView {
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  appUser?: AppUserObject = PersistenceV2.connect(AppUserObject, () => new AppUserObject())

  aboutToAppear(): void {
    // 下载混合开发压缩包的工具
  }

  build() {
    Column() {
      NavigationBar({
        title: '设置',
        onLeftClick: () => HMRouterMgr.pop()
      })
      Column({ space: 8 }) {
        // 头像昵称 还有账号
        CellGroup() {
          this.getProfileBuilder()
        }

        Blank() // 空格
        CellGroup() {
          Cell({
            title: '收货地址管理', onRightClick: () => HMRouterMgr.push({
              pageUrl: StackAddress.ADDRESS_PAGE
            })
          })
          Cell({ title: '账号安全' })
          Cell({ title: '消息设置' })
          Cell({ title: '隐私设置' })
          Cell({ title: '通用设置' })
        }

        Blank() // 空格

        CellGroup() {
          Cell({ title: '退出登录' })
            .onClick(async () => {
              const res = await this.getUIContext().getPromptAction().showDialog({
                title: '提示',
                message: '确定要退出登录吗?',
                buttons: [
                  {
                    text: '取消',
                    color: $r('app.color.red')
                  },
                  {
                    text: '确定',
                    color: $r('app.color.black'),
                  }
                ]
              })
              if (res.index == 1) {
                UserAuth.getInstance().setUser({} as LoginResponseViewModel)
                await CartManager.getInstance().updateCartCount()
                HuaweiLoginAuth.getInstance().logoutAuth()
                HMRouterMgr.pop()
              }
            })
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.under'))
  }

  @Builder getProfileBuilder() {
    RelativeContainer() {
      Image($r("app.media.ic_public_right"))
        .fillColor($r("app.color.gray"))
        .width(30)
        .aspectRatio(1)
        .alignRules({
          center: {
            anchor: '__container__',
            align: VerticalAlign.Center
          },
          right: {
            anchor: '__container__',
            align: HorizontalAlign.End
          }
        })
        .onClick(() => {

        })

      Image(this.appUser?.User?.avatar)
        .alt($r("app.media.ic_user_avatar"))
        .width(50)
        .aspectRatio(1)
        .borderRadius(25)
        .alignRules({
          center: {
            anchor: '__container__',
            align: VerticalAlign.Center
          }
        })
        .id("avatar")
      Column({ space: 4 }) {
        Text(this.appUser?.User.nickname ?? this.appUser?.User.account)
          .fontColor($r('app.color.black'))
          .fontWeight(500)
        Text('账号名：' + this.appUser?.User?.account)
          .fontColor($r('app.color.gray'))
          .fontSize(12)
      }

      .alignRules({
        center: {
          anchor: '__container__',
          align: VerticalAlign.Center
        },
        left: {
          anchor: 'avatar',
          align: HorizontalAlign.End
        }
      })
      .alignItems(HorizontalAlign.Start)
      .margin({
        left: 10
      })
    }
    .constraintSize({
      maxHeight: 100
    })
    .padding({ top: 16, bottom: 16 })
  }
}