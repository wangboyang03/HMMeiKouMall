import { BreakPoint } from "../models"
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