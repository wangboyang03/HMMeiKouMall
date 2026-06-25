import { HMRouter, HMRouterMgr } from "@hadss/hmrouter"
import { AppRecommend, AppSafeArea, DownloadManager, GoodsItem,
  LoadingCustomDialog,
  NavigationBar, StackAddress } from "basic"
import { AppStorageV2 } from "@kit.ArkUI"
import { getGuessDataApi } from '../api'
import common from "@ohos.app.ability.common"

@HMRouter({pageUrl: StackAddress.RECOMMEND_PAGE})
@Component
export struct RecommendView {
  // @State list: GoodsItem[] = []
  swiperController: SwiperController = new SwiperController()
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  recommendData?: AppRecommend = AppStorageV2.connect(AppRecommend, () => new AppRecommend())
  loadingDialog = new CustomDialogController({
    builder: LoadingCustomDialog({
      message: '好物马上就来'
    }),
    customStyle: true
  })

  async aboutToAppear(): Promise<void> {
    if (!this.recommendData?.recommendList.length) {
      this.loadingDialog.open()
      const res = await getGuessDataApi()
      this.recommendData!.recommendList = res.items
      this.loadingDialog.close()
    }
  }

  build() {
    Column() {
      Column() {
        // 顶部导航栏
        Stack({ alignContent: Alignment.TopStart }) {
          // banner
          Image($r("app.media.ic_public_hot_banner_bg"))
            .width('100%')
          NavigationBar({
            bgColor: Color.Transparent,
            onLeftClick: () => {
              HMRouterMgr.getPathStack(StackAddress.MAIN_PAGE_ID)?.clear()
              HMRouterMgr.pop()
            }
          })
        }

        // 轮播图
        Column() {
          Swiper(this.swiperController) {
            ForEach(this.recommendData?.recommendList, (item: GoodsItem) => {
                Column() {
                  Image(item.picture)
                    .width('100%')
                  Text(item.name)
                    .margin({
                      top: 10
                    })
                    .fontSize(14)
                    .fontColor('#434343')

                  Text(`￥${item.price}`)
                    .margin({
                      top: 10
                    })
                    .fontSize(20)
                    .fontColor('#191919')
                    .fontWeight(700)
                }
                .padding(30)
                .backgroundColor('#fff')
              }
            )
          }
          .width(270)
          .borderRadius(16)
          .indicator(
            new DotIndicator()
              .itemWidth(6)
              .itemHeight(6)
              .selectedItemWidth(6)
              .selectedItemHeight(6)
              .color('#E9E8EC')
              .selectedColor('#191919')
          )
        }
        .margin({
          top: -60
        })
      }
      .height('80%')
      .justifyContent(FlexAlign.Start)
      .linearGradient({
        angle: 180,
        colors: [
          ['#51E1F8', 0],
          ['#F5F4F9', 1]
        ]
      })

      // 操作按钮
      Row() {
        Row() {
          Text('换一批看看')
            .fontSize(16)
            .fontColor('#fff')
        }
        .width('100%')
        .height(46)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#00C6C6')
        .onClick(async () => {
          const res = await getGuessDataApi()
          for (let i = res.items.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1))
            const temp = res.items[i]
            res.items[i] = res.items[j]
            res.items[j] = temp
          }
          if (this.recommendData) {
            this.recommendData.recommendList = res.items
          }
        })
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16
      })
      .layoutWeight(1)
      .backgroundColor('#F5F4F9')
    }
  }
}