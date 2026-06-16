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
