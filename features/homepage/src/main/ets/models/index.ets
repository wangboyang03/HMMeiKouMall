import { GoodsItem } from "basic";

/**
 * 轮播图
 */
export interface Banner {
  id: string;
  imgUrl: string;
  type: string;
}

/**
 * 商品参数
 */
export interface Params {
  title: string,
  subTitle: string,
  bg: ResourceStr,
  list: GoodsItem[]
}

/**
 * 优惠类型
 */
export enum DiscountType {
  COMMAND,
  DISCOUNT,
  NEW
}

/**
 * 特惠推荐的接口
 */
export interface HotResult {
  id: string;
  subTypes: SubType[];
  title: string;
}

export interface SubType {
  goodsItems: GoodsItems;
  id: string;
  title: string;
}

export interface GoodsItems {
  counts: number;
  items: GoodsItem[];
  page: number;
  pages: number;
  pageSize: number;
}

/**
 * 获取首页猜喜区域请求参数
 */
export interface RecommendRequest {
  limit: number
}

// 联合类型
export type SortField = 'publishTime' | 'orderNum' | 'price'
// 升序和降序
export type SortMethod = 'desc' | 'asc'

// 提交给服务器的参数
@ObservedV2
export class SearchParams {
  // __ob_
  @Trace keyword: string = ""
  @Trace sortField: SortField = "publishTime"
  @Trace sortMethod: SortMethod = "desc"
  page: number = 1
  pageSize: number = 10
}

// 筛选条件
export interface SortCompAttr {
  field: SortField
  label: string
}

// 路由参数
export interface SearchRouterParam {
  keyword: string
}
