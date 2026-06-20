import { NetworkRequestUtil, UserAuth } from "."
import { AppStorageV2 } from "@kit.ArkUI"
import { CartCountObject, CartGoodsCount } from "../models"
import { Constants } from "../Constants"

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
    if (new CartCountObject()) {
      const appCart = AppStorageV2.connect(CartCountObject, () => new CartCountObject())
      if (!!appCart) {
        if (!!user?.token) {
          // 2.发生请求获取购物车数量
          const res = await NetworkRequestUtil.get<CartGoodsCount>(Constants.CART_COUNT_API)
          appCart.count = res.count // 3.赋值全局购物车数量状态
        } else {
          appCart.count = 0
        }
      }
    }
  }
}