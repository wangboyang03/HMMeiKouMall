import { Type } from "@kit.ArkUI";

export interface ResponseData<T> {
  code: number;
  message: string;
  result: T;
}

export interface LoginResponse {
  account: string;
  avatar: string;
  birthday: string;
  cityCode: string;
  gender: string;
  id: string;
  mobile: string;
  nickname: string;
  profession: string;
  provinceCode: string;
  token: string;
}

@ObservedV2 export class LoginResponseViewModel implements LoginResponse{
  @Trace account: string = ""
  @Trace avatar: string = ""
  @Trace birthday: string = ""
  @Trace cityCode: string = ""
  @Trace gender: string = ""
  @Trace id: string = ""
  @Trace mobile: string = ""
  @Trace nickname: string = ""
  @Trace profession: string = ""
  @Trace provinceCode: string = ""
  @Trace token: string = ""

  // 修饰的类不能有构造函数，所以需要去掉原来的构造函数
  /*constructor(models: LoginResponse) {
    this.account = models.account
    this.avatar = models.avatar
    this.birthday = models.birthday
    this.cityCode = models.cityCode
    this.gender = models.gender
    this.id = models.id
    this.mobile = models.mobile
    this.nickname = models.nickname
    this.profession = models.profession
    this.provinceCode = models.provinceCode
    this.token = models.token
  }*/
}

@ObservedV2 export class AppUserObject {
  // 当缓存的对象为复杂数据类型时 需要用@Type装饰器装饰这个类 保证不丢失
  @Type(LoginResponseViewModel) @Trace User: LoginResponseViewModel = new LoginResponseViewModel()
}

/** 购物车信息 */
export interface CartGoodsItem {
  attrsText: string;
  count: number;
  discount: null;
  id: string;
  isCollect: boolean;
  isEffective: boolean;
  name: string;
  nowOriginalPrice: string;
  nowPrice: string;
  picture: string;
  postFee: number;
  price: string;
  selected: boolean;
  skuId: string;
  specs: string[];
  stock: number;
}

export class CartGoodsItemModel implements CartGoodsItem {
  attrsText: string = ''
  count: number = 0
  discount: null = null
  id: string = ''
  isCollect: boolean = false
  isEffective: boolean = false
  name: string = ''
  nowOriginalPrice: string = ''
  nowPrice: string = ''
  picture: string = ''
  postFee: number = 0
  price: string = ''
  selected: boolean = false
  skuId: string = ''
  specs: string[] = []
  stock: number = 0

  constructor(model: CartGoodsItem) {
    this.attrsText = model.attrsText
    this.count = model.count
    this.discount = model.discount
    this.id = model.id
    this.isCollect = model.isCollect
    this.isEffective = model.isEffective
    this.name = model.name
    this.nowOriginalPrice = model.nowOriginalPrice
    this.nowPrice = model.nowPrice
    this.picture = model.picture
    this.postFee = model.postFee
    this.price = model.price
    this.selected = model.selected
    this.skuId = model.skuId
    this.specs = model.specs
    this.stock = model.stock
  }
}

/** 新增购物车 */
export interface AddCartGoodsItem {
  count: string;
  skuId: string;
}

/** 购物车商品数量 */
export interface CartGoodsCount {
  count: number;
}

@ObservedV2 export class CartGoodsObject {
  // 购物车数量
  @Trace count: number = 0
  // 购物车商品列表
  @Trace cartGoodsList: CartGoodsItemModel[] = []
}

/**
 * 修改购物车
 */
export interface CartItemRequest {
  count?: string;
  selected?: boolean;
}

/**
 * 删除购物车
 */
export interface DeleteCartItem {
  /**
   * skuId组成的数组
   */
  ids: string[];
}

// 地址
export interface UserAddress {
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

// 订单
export interface OrderGoodsItem {
  attrsText: string;
  count: number;
  id: string;
  name: string;
  payPrice: string;
  picture: string;
  price: string;
  skuId: string;
  totalPayPrice: string;
  totalPrice: string;
}

// 摘要
export interface Summary {
  discountPrice: number;
  goodsCount: number;
  postFee: number;
  totalPayPrice: number;
  totalPrice: number;
}

// 结算信息
export interface PreOrder {
  goods: OrderGoodsItem[]
  userAddresses: UserAddress[]
  summary: Summary
}

// 创建订单商品信息
export interface CreateOrderParamsGoods {
  skuId: string
  count: number
}

// 生成订单参数
export interface CreateOrderParams {
  deliveryTimeType: number
  payType: number
  buyerMessage: string
  payChannel: number
  goods: CreateOrderParamsGoods[]
  addressId: string
}

// 创建订单结果
export interface CreateOrderResult {
  id: string
}

// 订单
export interface OrderItem {
  countdown: number;
  createTime: string;
  id: string;
  orderState: 1 | 2 | 3 | 4 | 5 | 6;
  payChannel: number;
  payLatestTime: string;
  payMoney: number;
  payType: number;
  postFee: number;
  skus: OrderSku[];
  totalMoney: number;
  totalNum: number;
}

// 订单 sku
export interface OrderSku {
  attrsText: string;
  curPrice: number;
  id: string;
  image: string;
  name: string;
  properties: Property[];
  quantity: number;
  realPay: number;
  spuId: string;
}

// 属性
export interface Property {
  propertyMainName: string;
  propertyValueName: string;
}

// 获取订单列表
export interface OrderListResponse {
  counts: number;
  items: OrderItem[];
  page: number;
  pages: number;
  pageSize: number;
}

export interface OrderListRequest {
  orderState?: string;
  page?: string;
  pageSize?: string;
}