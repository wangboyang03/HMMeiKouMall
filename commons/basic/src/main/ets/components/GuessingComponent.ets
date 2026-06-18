import { BreakPoint, GoodsItem, GuessLikeResponse, GuessRequest } from "../models"
import { Goods } from "./Goods"
import { AppStorageV2 } from "@kit.ArkUI"
import { BreakPointType, NetworkRequestUtil } from "../utils"
import { BreakPointEnum, Constants } from "../Constants"

@ComponentV2
export struct GuessingComponent {
  @Local recommendGoods: GoodsItem[] = []
  breakPointObject?: BreakPoint = AppStorageV2.connect(BreakPoint, () => new BreakPoint())
  @Param requestParams: GuessRequest = {
    page: 1,
    pageSize: 10
  }
  // 触底加载状态变量
  @Local isLoading: boolean = false
  @Local isFinished: boolean = false

  async getRecommendGoodsData() {
    // 封装接口
    const getRecommendGoodsDataApi = (params: GuessRequest) => NetworkRequestUtil.get<GuessLikeResponse>(Constants.GUESS_LICK_API, params)
    const res = await getRecommendGoodsDataApi(this.requestParams)
    this.recommendGoods.push(...res.items)
    if (this.requestParams.page >= res.pages) {
      // 表示没有更多数据了
      this.isFinished = true
    } else {
      this.requestParams.page++
    }
  }

  aboutToAppear(): void {
    this.getRecommendGoodsData()
  }

  build() {
    Column({ space: 8 }) {
      Text('猜你喜欢')
        .fontSize(14)
        .width('100%')
        .padding({ left: 8, top: 8 })
        .lineHeight(22)
        .fontWeight(500)
      WaterFlow() {
        ForEach(this.recommendGoods, (item: GoodsItem) => {
          FlowItem() {
            Goods({
              goods: item
            })
          }
        })
      }
      .columnsTemplate(
        new BreakPointType({
          sm: '1fr 1fr',
          md: '1fr 1fr 1fr',
          lg: '1fr 1fr 1fr 1fr'
        }).getValue(this.breakPointObject?.breakPoint ?? BreakPointEnum.SM)
      )
      .columnsGap(8)
      .rowsGap(10)
      .onReachEnd(async () => {
        if (!this.isLoading && !this.isFinished) {
          this.isLoading = true
          await this.getRecommendGoodsData()
          this.isLoading = false
        }
      })
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST, // 父级优先滑动
        scrollBackward: NestedScrollMode.SELF_FIRST // 自身优先滑动
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.white'))
    .borderRadius(10)
  }
}