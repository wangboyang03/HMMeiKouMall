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
