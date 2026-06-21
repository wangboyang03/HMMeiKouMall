import { authentication } from "@kit.AccountKit";
import { util } from "@kit.ArkTS";
import { hilog } from "@kit.PerformanceAnalysisKit";

export class HuaweiLoginAuth {
  private static sInstance: HuaweiLoginAuth
  private constructor() {} // 私有构造函数

  // 单例实例
  public static getInstance(): HuaweiLoginAuth {
    if (!HuaweiLoginAuth.sInstance) {
      HuaweiLoginAuth.sInstance = new HuaweiLoginAuth()
    }
    return HuaweiLoginAuth.sInstance
  }

  async launchAuth() {
    try {
      // 创建授权请求，并设置参数
      const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest()
      // 获取手机号需要传如下scope，传参数之前需要先申请对应scope权限,才能返回对应数据
      authRequest.scopes = ['phone']
      // 获取code需传如下permission
      authRequest.permissions = ['serviceauthcode']
      // 用户是否需要登录授权，该值为true且用户未登录或未授权时，会拉起用户登录或授权页面
      authRequest.forceAuthorization = true
      // 用于防跨站点请求伪造
      authRequest.state = util.generateRandomUUID()
      const controller = new authentication.AuthenticationController(getContext(this))
      const data = await controller.executeRequest(authRequest) as authentication.AuthorizationWithHuaweiIDResponse
      const state = data?.state
      if (state == authRequest.state) {
        // 获取授权码
        const code = data?.data?.authorizationCode
        // const unionID = data?.data?.unionID
        // const openID = data?.data?.openID
        return code
      }
      return
    } catch (error) {
      hilog.error(0x0000, 'testTag', `Failed to authorize. Error message: ${error.message}`);
      return
    }
  }

  async logoutAuth() {
    const cancelRequest = new authentication.HuaweiIDProvider().createCancelAuthorizationRequest()
    const controller = new authentication.AuthenticationController()
    await controller.executeRequest(cancelRequest)
  }
}