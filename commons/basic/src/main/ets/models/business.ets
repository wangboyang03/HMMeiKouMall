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