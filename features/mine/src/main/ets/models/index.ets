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

/**
 * 地址管理
 */
export interface AddressResponse {
  address: string;
  addressTags: string;
  cityCode: string;
  contact: string;
  countyCode: string;
  fullLocation: string;
  id: string;
  isDefault: number;
  postalCode: string;
  provinceCode: string;
  receiver: string;
}

/**
 * 新增地址请求
 */
export interface AddAddressRequest {
  /**
   * 地址
   */
  address: string;
  /**
   * 收货人电话
   */
  contact: string;
  /**
   * 是否默认，0(默认) 或 1
   */
  isDefault: number;
  /**
   * 收货人名称
   */
  receiver: string;
  id?: string;
}

export interface TextInputParams {
  label: string;
  value: string;
  address?: AddressForm;
}

/**
 * 地址表单
 */
@ObservedV2 export class AddressForm {
  id?: string
  @Trace address: string = "";
  contact: string = "";
  /**
   * 0(默认) 或 1
   */
  isDefault: number = 0;
  receiver: string = "";

  constructor(item: AddAddressRequest) {
    this.id = item.id
    this.address = item.address
    this.contact = item.contact
    this.receiver = item.receiver
    this.isDefault = item.isDefault
  }
}