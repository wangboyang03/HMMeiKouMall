import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { AppRecommend, Constants, ContextData, DownloadManager, Logger, ScreenAreaManager, ScreenManager, StackAddress } from 'basic';
import { getGuessDataApi } from "mine";

import { HMRouterMgr } from '@hadss/hmrouter';
import { rpc } from '@kit.IPCKit';
import { formBindingData, formProvider } from '@kit.FormKit';

const DOMAIN = 0x0000;

class Params implements rpc.Parcelable {
  marshalling(messageSequence: rpc.MessageSequence): boolean {
    return true
  }
  unmarshalling(messageSequence: rpc.MessageSequence): boolean {
    return true
  }
}

export default class PhoneAbility extends UIAbility {
  screenManager?: ScreenManager
  private targetPage?: string
  private timer?: number

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    HMRouterMgr.init({context: this.context}) // 初始化HMRouter
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      AppStorageV2.connect(ContextData, () => new ContextData(this.context)) // 持久化上下文对象

      // 记录卡片参数 不能跳转
      if (want.parameters?.targetPage) {
        this.targetPage = want.parameters?.targetPage as string
      }

      this.callee.on(Constants.REFRESH_IMAGE_LIST, (data) => {
        const res = JSON.parse(data.readString()) as Record<string, string>
        // Logger.info(res)
        getGuessDataApi().then(async (data) => {
          data.items.sort(() => Math.random() - 0.5) // 打乱数组顺序 直接打乱 res.items,不要封装函数，直接打乱
          const urls = data.items.slice(0, 2).map(value => value.picture as string)  // 获取开头两个图片地址
          const downLoadImages = await DownloadManager.getInstance().downloadImageList(this.context, urls) // 下载图片到沙箱返回沙箱地址
          const formImages = DownloadManager.getInstance().createFormImages(downLoadImages) // 转成FormImage对象
          // 下载完毕通知卡片刷新
         formProvider.updateForm(res.formId, formBindingData.createFormBindingData({
           formImages,
           imageList: downLoadImages
          }))
          Logger.error(downLoadImages)
          // 这样做是为了让卡片看到的内容和点进去的内容一致
          const appRecommendData = AppStorageV2.connect(AppRecommend, () => new AppRecommend())
          if (appRecommendData) {
            appRecommendData.recommendList = data.items
          }
        })
        return new Params() // 只是为了不报错
      })

    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onNewWant(want: Want, _: AbilityConstant.LaunchParam): void {
    // 热启动
    if (want.parameters?.targetPage) {
      // 根据 want 的参数打开指定页面
      HMRouterMgr.getPathStack(StackAddress.MAIN_PAGE_ID)?.clear()
      HMRouterMgr.push({
        pageUrl: want.parameters.targetPage as string,
        animator: false
      })
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    this.screenManager = new ScreenManager(this.context)
    this.screenManager.initBreakPoint() // 初始化断点工具并监听窗口宽度变化
    ScreenAreaManager.getInstance().openFullScreen(this.context) // 开启全屏模式

    // 此时可以跳转
    this.timer = setTimeout(()=>{
      if (this.targetPage) {
        HMRouterMgr.push({
          pageUrl: this.targetPage
        })
      }
    }, 100)
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    this.screenManager?.unregister()
    ScreenAreaManager.getInstance().closeFullScreen(this.context) // 关闭全屏模式
    clearTimeout(this.timer)
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}