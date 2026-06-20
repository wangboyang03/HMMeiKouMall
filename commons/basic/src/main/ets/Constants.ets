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

  // 包相关信息
  static readonly HOMEPAGE_MODULE_NAME = "homepage" // 首页模块名称
  static readonly REFRESH_PROMPT_SOUND = "sound.mp3" // 刷新提示音

  // 接口地址
  static readonly BANNER_API = "home/banner" // 首页轮播图
  static readonly CATEGORY_API = "home/category/head" // 首页分类
  static readonly HOT_RESULT_API = "hot/preference" // 特惠推荐
  static readonly HOT_INVOGUE_API = "hot/inVogue"  // 爆款推荐
  static readonly ONESTOP_API = "hot/oneStop" // 一站买全
  static readonly HOME_NEW_API = "home/new" // 新鲜好物
  static readonly HOME_RECOMMEND_API = "home/recommend" // 猜喜推荐
  static readonly Search_Result_API = "search/all" // 搜索结果
  static readonly GUESS_LICK_API = "home/goods/guessLike" // 猜你喜欢
  static readonly LOGIN_API = "login" // 登录-账号密码登录
  static readonly GOODS_DETAIL_API = "goods" // 详情-获取详情信息
}

export class StackAddress {
  static readonly MAIN_PAGE = "HomePage"
  static readonly MAIN_PAGE_ID = "MainNavigation"
  static readonly SEARCH_PAGE = "SearchView"
  static readonly SEARCH_RESULT_PAGE = "SearchResultView"
  static readonly LOGIN_PAGE = "LoginView"
  static readonly SETTING_PAGE = "SettingView"
  static readonly GOODS_PAGE = "GoodsView" // 商品详情页面
}