import { abilityAccessCtrl, Permissions } from "@kit.AbilityKit";
import { Constants } from "../Constants";

export class ATManager {
  private static sInstance: ATManager;
  mContext?: Context
  private constructor() {}

  public static getInstance(): ATManager {
    if (!ATManager.sInstance) {
      ATManager.sInstance = new ATManager();
    }
    return ATManager.sInstance;
  }

  async getAccessFromUser(PermissionsList: Array<Permissions>) {
    try {
      const atManager = abilityAccessCtrl.createAtManager()
      if (!!this.mContext) {
        const result = await atManager.requestPermissionsFromUser(this.mContext, PermissionsList)
        const flag = result.authResults.every(item => item == abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) // 遍历每个权限是否都被授权
        return flag
      }
      return false
    } catch (error) {
      return false
    }
  }

  async getAccessFromSetting(PermissionsList: Array<Permissions>) {
    try {
      const atManager = abilityAccessCtrl.createAtManager()
      if (!!this.mContext) {
        const result = await atManager.requestPermissionOnSetting(this.mContext, PermissionsList)
        const flag = result.every(item => item == abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
        return flag
      }
      return false
    } catch (error) {
      return false
    }
  }
}