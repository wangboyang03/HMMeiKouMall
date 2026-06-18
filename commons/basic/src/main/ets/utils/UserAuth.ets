import { AppUserObject, LoginResponse, LoginResponseViewModel } from "../models"
import { AppStorageV2 } from "@kit.ArkUI"

export class UserAuth {
  private static sInstance: UserAuth
  private constructor() {} // 私有构造函数

  /**
   * 获取单例
   * @returns
   */
  public static getInstance(): UserAuth {
    if (!UserAuth.sInstance) {
      UserAuth.sInstance = new UserAuth()
    }
    return UserAuth.sInstance
  }

  /**
   * 存储用户信息
   * @param User
   */
  setUser(User: LoginResponseViewModel) {
    const UserObject = AppStorageV2.connect(AppUserObject, () => new AppUserObject())
    if (UserObject) {
      UserObject.User = User
    }
  }

  /**
   * 获取用户信息
   * @returns
   */
  getUser() {
    const UserObject = AppStorageV2.connect(AppUserObject, () => new AppUserObject())
    if (UserObject) {
      return UserObject.User
    }
    return
  }
}