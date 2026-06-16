export enum BreakPointEnum {
  XS = "xs",
  SM = "sm",
  MD = "md",
  LG = "lg",
  XL = "xl"
}

export class Constants {
  static readonly BASE_URL = "https://meikou-api.itheima.net/" // 基地址
  static readonly SUCCESS_CODE = 1 // 请求成功码
  static readonly TIME_OUT = 10000 // 请求超时时间

  // 接口地址
  static readonly BANNER_API = "home/banner" // 首页轮播图
  static readonly CATEGORY_API = "home/category/head" // 首页分类
  static readonly HOT_RESULT_API = "hot/preference" // 特惠推荐
  static readonly HOT_INVOGUE_API = "hot/inVogue"  // 爆款推荐
  static readonly ONESTOP_API = "hot/oneStop" // 一站买全
  static readonly HOME_NEW_API = "home/new" // 新鲜好物
}