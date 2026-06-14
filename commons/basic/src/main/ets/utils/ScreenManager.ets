import { AppSafeArea, BreakPoint } from "../models"
import { AppStorageV2, window } from "@kit.ArkUI"
import { Logger } from "."
import { BreakPointEnum } from "../Constants"

export class ScreenManager {
  context:Context
  appBreakPoint?: BreakPoint = AppStorageV2.connect(BreakPoint, () => new BreakPoint())

  constructor(mContext:Context) {
    this.context = mContext
  }

  async initBreakPoint() {
    try {
      const windowObject = await window.getLastWindow(this.context)
      const windowWidth = windowObject.getWindowProperties().windowRect.width
      this.getBreakPoint(px2vp(windowWidth))
      windowObject.on('windowSizeChange', (size) => {
        this.getBreakPoint(px2vp(size.width))
      })
    } catch (error) {
      Logger.error(error)
    }
  }

  getBreakPoint(windowWidth: number) {
    try {
      let currentBreakPoint: BreakPointEnum = BreakPointEnum.SM
      if (windowWidth < 320) {
        currentBreakPoint = BreakPointEnum.XS
      } else if (windowWidth < 600) {
        currentBreakPoint = BreakPointEnum.SM
      } else if (windowWidth < 840) {
        currentBreakPoint = BreakPointEnum.MD
      } else if (windowWidth < 1440) {
        currentBreakPoint = BreakPointEnum.LG
      } else {
        currentBreakPoint = BreakPointEnum.XL
      }
      if (this.appBreakPoint?.breakPoint != currentBreakPoint) {
        if (this.appBreakPoint) {
          this.appBreakPoint.breakPoint = currentBreakPoint
        }
      }
    } catch (error) {
      Logger.error(error)
    }
  }

  async unregister() {
    try {
      const windowObject = await window.getLastWindow(this.context)
      windowObject.off('windowSizeChange')
    } catch (error) {
      Logger.error(error)
    }
  }
}

export class ScreenAreaManager {
  private static sInstance: ScreenAreaManager
  private constructor() {}

  public static getInstance(): ScreenAreaManager {
    if (!ScreenAreaManager.sInstance) {
      ScreenAreaManager.sInstance = new ScreenAreaManager()
    }
    return ScreenAreaManager.sInstance
  }

  // 开启全屏模式
  async openFullScreen(context: Context) {
    try {
      const windowObject = await window.getLastWindow(context)
      await windowObject.setWindowLayoutFullScreen(true)
      const topAreaHeight = windowObject.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
      const bottomAreaHeight = windowObject.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
      const safeAreaValue = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
      if (!!safeAreaValue) {
        safeAreaValue.topHeight = px2vp(topAreaHeight.topRect.height)
        safeAreaValue.bottomHeight = px2vp(bottomAreaHeight.bottomRect.height)
      }
    } catch (error) {
      Logger.error(error)
    }
  }

  // 关闭全屏模式
  async closeFullScreen(context: Context) {
    try {
      const windowObject = await window.getLastWindow(context)
      await windowObject.setSystemAvoidAreaEnabled(false)
      const safeAreaValue = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
      if (!!safeAreaValue) {
        safeAreaValue.topHeight = 0
        safeAreaValue.bottomHeight = 0
      }
    } catch (error) {
      Logger.error(error)
    }
  }
}