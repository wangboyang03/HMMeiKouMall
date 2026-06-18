export interface TabItemParams {
  text: string
  normal: ResourceStr
  active: ResourceStr
}

/**
 * 商品项
 */
export interface GoodsItem {
  id: string
  name: string
  desc: string
  price: string
  picture: ResourceStr
  orderNum: number
}

/**
 * 分类项
 */
export interface CategoryItem {
  children?: CategoryItemChild[]
  goods?: GoodsItem[]
  id: string
  name: string
  picture: ResourceStr
}

/**
 * 分类项子项
 */
export interface CategoryItemChild {
  id: string
  name: string
  picture: ResourceStr
}

export interface GuessRequest {
  page: number;
  pageSize: number;
}

export interface GuessLikeResponse {
  counts: number;
  items: GoodsItem[];
  page: number;
  pages: number;
  pageSize: number;
}