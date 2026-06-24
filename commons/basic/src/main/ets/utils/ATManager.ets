import { abilityAccessCtrl, Permissions } from "@kit.AbilityKit";
import { AppStorageV2 } from "@kit.ArkUI";
import { ContextData } from "../models/appDataShare";

export class ATManager {
  private static sInstance: ATManager;
  // mContext?: Context
  private constructor() {}

  public static getInstance(): ATManager {
    if (!ATManager.sInstance) {
      ATManager.sInstance = new ATManager();
    }
    return ATManager.sInstance;
  }

  /**
   * 首次拉起用户授权
   * @param PermissionsList 权限列表
   * @returns boolean 是否授权成功
   */
  async getAccessFromUser(PermissionsList: Array<Permissions>) {
    const atManager = abilityAccessCtrl.createAtManager() // 创建ATManager
    const context = AppStorageV2.connect(ContextData)?.context
    if (context) {
      const res = await atManager.requestPermissionsFromUser(context, PermissionsList)
      return res.authResults.every((res) => res == abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
    }
    return false
  }

  /**
   * 跳转系统设置授权
   * @param PermissionsList
   * @returns boolean 是否授权成功
   */
  async getAccessFromSetting(PermissionsList: Array<Permissions>) {
    const atManager = abilityAccessCtrl.createAtManager()
    const context = AppStorageV2.connect(ContextData)?.context
    if (context) {
      const res = await atManager.requestPermissionOnSetting(context, PermissionsList)
      return res.every((res) => res == abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
    }
    return false
  }

  /**
   * 检查权限状态
   * @param PermissionsList 权限列表
   * @returns boolean 是否授权成功
   */
  async checkPermissions(PermissionsList: Array<Permissions>) {
    const firstResponse = await this.getAccessFromUser(PermissionsList)
    if (firstResponse) {
      return Promise.resolve(true)
    }
    const secondResponse = await this.getAccessFromSetting(PermissionsList)
    if (secondResponse) {
      return Promise.resolve(true)
    }
    return Promise.reject(false)
  }
}