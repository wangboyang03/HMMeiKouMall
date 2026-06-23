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
  static readonly SWITCH_HOMEPAGE = "switch_homepage_event" // 切换首页事件名

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
  static readonly ADD_CART_API = "member/cart" // 购物车-新增购物车
  static readonly CART_COUNT_API = "member/cart/count" // 购物车-数量
  static readonly CART_LIST_API = "member/cart" // 购物车-购物车列表
  static readonly CART_MODIFY_API = "member/cart/" // 购物车-修改单项
  static readonly CART_SELECTED_API = "member/cart/selected" // 购物车-全选/取消全选
  static readonly CART_DELETE_API = "member/cart" // 购物车-删除
  static readonly HUAWEI_LOGIN_REQUEST_API = "login/huawei" // 华为登录请求
  static readonly GET_ADDRESS_API = "member/address" // 地址管理-获取列表
  static readonly ADD_ADDRESS_API = "member/address" // 地址管理-新增
  static readonly PRE_ORDER_API = "member/order/pre" // 订单-获取结算信息
}

export class StackAddress {
  static readonly MAIN_PAGE = "HomePage"
  static readonly MAIN_PAGE_ID = "MainNavigation"
  static readonly SEARCH_PAGE = "SearchView"
  static readonly SEARCH_RESULT_PAGE = "SearchResultView"
  static readonly LOGIN_PAGE = "LoginView"
  static readonly SETTING_PAGE = "SettingView"
  static readonly GOODS_PAGE = "GoodsView" // 商品详情页面
  static readonly CART_PAGE = "CartView" // 购物车页面
  static readonly ADDRESS_PAGE = "AddressView" // 地址页面
  static readonly EDIT_ADDRESS_PAGE = "EditAddressView" // 地址编辑页面
  static readonly CHECK_PAGE = "CheckView" // 订单页面
}