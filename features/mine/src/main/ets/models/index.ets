export interface LoginForm {
  account: string
  password: string
}

@ObservedV2 export class LoginFormViewModel implements LoginForm {
  @Trace account: string = ""
  @Trace password: string = ""

  constructor(models: LoginForm) {
    this.account = models.account
    this.password = models.password
  }
}

/**
 * 华为登录
 */
export interface HuaweiLoginRequest {
  /**
   * 客户端id
   */
  clientId: string;
  /**
   * 客户端秘钥
   */
  clientSecret: string;
  /**
   * 华为授权码
   */
  code: string;
}