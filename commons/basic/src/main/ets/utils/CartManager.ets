import { NetworkRequestUtil, UserAuth } from "."
import { AppStorageV2 } from "@kit.ArkUI"
import { CartGoodsObject, CartGoodsCount, CartGoodsItemModel } from "../models"
import { Constants } from "../Constants"
import { Logger } from "./Logger"

export class CartManager {
  private static sInstance: CartManager
  private constructor() {}

  /**
   * 获取单例
   * @returns
   */
  public static getInstance(): CartManager {
    if (!CartManager.sInstance) {
      CartManager.sInstance = new CartManager()
    }
    return CartManager.sInstance
  }

  async updateCartCount() {
    // 1.判断是否登录
    const user = UserAuth.getInstance().getUser()
    if (new CartGoodsObject()) {
      const appCart = AppStorageV2.connect(CartGoodsObject, () => new CartGoodsObject())
      if (!!appCart) {
        if (!!user?.token) {
          try {
            // 2.发生请求获取购物车数量
            const res = await NetworkRequestUtil.get<CartGoodsCount>(Constants.CART_COUNT_API)
            appCart.count = res.count // 3.赋值全局购物车数量状态
            // 获取购物车商品列表
            const list = await NetworkRequestUtil.get<CartGoodsItemModel[]>(Constants.CART_LIST_API)
            // appCart.cartGoodsList = list // 错误写法 此时接口返回的是普通对象 不是被new实例化后的类对象 不具备响应式!!!
            appCart.cartGoodsList = list.map((item) => new CartGoodsItemModel(item))
          } catch (error) {
            Logger.error(error)
          }
        } else {
          appCart.count = 0
          appCart.cartGoodsList = []
        }
      }
    }
  }
}