import { CategoryItem, Constants, GoodsItem, Logger, NetworkRequestUtil } from "basic"
import { Banner, HotResult, RecommendRequest } from "../models"

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