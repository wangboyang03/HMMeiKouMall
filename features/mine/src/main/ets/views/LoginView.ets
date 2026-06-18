import { AppSafeArea, Logger, NavigationBar, StackAddress, UserAuth } from 'basic'
import { AppStorageV2 } from '@kit.ArkUI'

import { HMRouter, HMRouterMgr } from '@hadss/hmrouter'
import { LoginFormViewModel } from '../models'
import { LoginRequestApi } from '../api'

@Preview
@HMRouter({ pageUrl: StackAddress.LOGIN_PAGE })
@ComponentV2
export struct LoginView {
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  // @Local account: string = '13200000010'
  // @Local password: string = '123456'
  loginForm: LoginFormViewModel = new LoginFormViewModel({
    account: '13200000010',
    password: '123456'
  })
  @Local agree: boolean = false
  @Computed get buttonEnable() {
    // 手机号校验
    const phoneReg = /^1[3-9]\d{9}$/
    // 去除前后空格
    const account = this.loginForm.account.trim()
    const password = this.loginForm.password.trim()
    return phoneReg.test(account) && password.length >= 6
  }


  aboutToAppear(): void {

  }

  async onSubmit() {
    if (!this.agree) {
      this.getUIContext().getPromptAction().openToast({ message: '请先勾选协议' })
    }
    try {
      const res = await LoginRequestApi(this.loginForm)
      UserAuth.getInstance().setUser(res)
      HMRouterMgr.pop()
    } catch (error) {
      Logger.error(error)
    }
  }

  @Styles form() {
    .width('100%')
    .height(42)
    .padding({
      left: 16,
      right: 16,
      top: 0,
      bottom: 0
    })
  }

  build() {
    Column() {
      NavigationBar({
        title: '商城登录',
        onLeftClick: () => HMRouterMgr.pop()
      })
      Column({ space: 16 }) {
        Text('账号密码登录')
          .fontSize(18)
          .fontColor($r('app.color.black'))
          .width('100%')
          .fontWeight(500)
          .margin({ bottom: 10 })
        TextInput({ placeholder: '请输入账号', text: this.loginForm.account!! })
          .placeholderColor($r('app.color.gray'))
          .placeholderFont({ size: 14 })
          .form()
        TextInput({ placeholder: '请输入密码', text: this.loginForm.password!! })
          .type(InputType.Password)
          .showPasswordIcon(false)
          .placeholderColor($r('app.color.gray'))
          .placeholderFont({ size: 14 })
          .form()

        Row({ space: 4 }) {
          Checkbox()
            .select($$this.agree)
            .width(12)
            .aspectRatio(1)
            .selectedColor($r('app.color.black'))
            .mark({ size: 10, strokeWidth: 1 })
          Text() {
            Span('查看并同意')
            Span('《隐私条款》')
              .fontColor('#007DFB')
            Span('和')
            Span('《用户协议》')
              .fontColor('#007DFB')
          }
          .width('100%')
          .fontSize(12)
          .fontColor($r('app.color.gray'))
        }

        Button('登录')
        // .backgroundColor(this.valid ? $r('app.color.black') : '#D4D2D9')
          .fontColor($r('app.color.white'))
          .form()
          .onClick(() => this.onSubmit())
          .enabled(this.buttonEnable)

        Row() {
          Blank()
          Text('忘记密码')
            .fontColor('#007DFB')
            .fontSize(12)
        }
        .width('100%')

        Column({ space: 16 }) {
          Stack() {
            Text()
              .width(200)
              .height(1)
              .backgroundColor($r('app.color.under'))
            Text('其他登录方式')
              .width(100)
              .fontSize(12)
              .backgroundColor($r('app.color.white'))
              .fontColor($r('app.color.text'))
              .textAlign(TextAlign.Center)
          }

          Row() {
            // 后续放置华为登录
          }
        }
        .margin({ top: 200 })
      }
      .padding(30)
    }
    .width('100%')
    .height('100%')
    .padding({
      bottom: this.safeAreaValue?.bottomHeight
    })
  }
}

