import { AddCartGoodsItem, CategoryItem, Constants, GoodsItem, Logger, NetworkRequestUtil } from "basic"
import { Banner, HotResult, RecommendRequest, SearchResult, SearchParams, GoodsDetailRequest, Goods } from "../models"

/**
 * 获取轮播图数据
 */
export const getBannerDataApi = () => NetworkRequestUtil.get<Banner[]>(Constants.BANNER_API)

/**
 * 获取首页分类
 */
export const getCategoryApi = () => NetworkRequestUtil.get<CategoryItem[]>(Constants.CATEGORY_API)

/**
 * 获取特惠推荐
 */
export const getHotResultApi = () => NetworkRequestUtil.get<HotResult>(Constants.HOT_RESULT_API)

/**
 * 获取爆款推荐
 */
export const getInVogueApi = () => NetworkRequestUtil.get<HotResult>(Constants.HOT_INVOGUE_API)

/**
 * 获取一站买全
 */
export const  getOneStopApi = () => NetworkRequestUtil.get<HotResult>(Constants.ONESTOP_API)

/**
 * 获取新鲜好物
 */
export const getNewGoodsApi = () => NetworkRequestUtil.get<GoodsItem[]>(Constants.HOME_NEW_API)

/**
 * 获取猜喜推荐数据
 */
export const getRecommendApi = (params: RecommendRequest) => NetworkRequestUtil.get<GoodsItem[]>(Constants.HOME_RECOMMEND_API, params)

/**
 * 获取搜索内容数据
 */
export const getSearchResultApi = (data: SearchParams) => NetworkRequestUtil.post<SearchResult>(Constants.Search_Result_API, data)

/**
 * 获取商品详情页
 */
export const getGoodsDetailApi = (params: GoodsDetailRequest) => NetworkRequestUtil.get<Goods>(Constants.GOODS_DETAIL_API, params)

/**
 * 加入商品到购物车
 */
export const addGoodsToCartApi = (data: AddCartGoodsItem) => NetworkRequestUtil.post<null>(Constants.ADD_CART_API, data)