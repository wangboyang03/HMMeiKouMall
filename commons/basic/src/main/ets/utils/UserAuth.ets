import { AppUserObject, LoginResponse, LoginResponseViewModel } from "../models"
import { AppStorageV2, PersistenceV2 } from "@kit.ArkUI"

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
    const UserObject = PersistenceV2.connect(AppUserObject, () => new AppUserObject())
    if (UserObject) {
      // UserObject.User = User
      UserObject.User.account = User.account
      UserObject.User.token = User.token
      UserObject.User.avatar = User.avatar
      UserObject.User.id = User.id
      UserObject.User.nickname = User.nickname
      UserObject.User.birthday = User.birthday
      UserObject.User.cityCode = User.cityCode
      UserObject.User.provinceCode = User.provinceCode
      UserObject.User.gender = User.gender
      UserObject.User.mobile = User.mobile
      UserObject.User.profession = User.profession

      PersistenceV2.notifyOnError((key: string, reason: string, msg: string) => {
        AlertDialog.show({ message: reason + msg })
      })
      PersistenceV2.save("AppUser")
    }
  }

  /**
   * 获取用户信息
   * @returns
   */
  getUser() {
    const UserObject = PersistenceV2.connect(AppUserObject, () => new AppUserObject())
    if (UserObject) {
      return UserObject.User
    }
    return
  }
}