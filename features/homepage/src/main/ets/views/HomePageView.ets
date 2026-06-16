import { AppSafeArea, BasicDataSource, BreakPoint, BreakPointEnum, BreakPointType, CategoryItem,
  Constants,
  GoodsItem, LoadingAnimator, Logger, ProgressLoading,
  SoundPool } from "basic"
import { DiscountGoods, Goods } from "../components"
import { Banner, Params, DiscountType, HotResult } from "../models"
import { AppStorageV2 } from "@kit.ArkUI"
import { getBannerDataApi, getCategoryApi, getHotResultApi, getInVogueApi, getOneStopApi, getNewGoodsApi, getRecommendApi } from "../api"

@ComponentV2
export struct HomePageView {
  // 轮播图
  @Local banners: Banner[] = []
  // 分类
  @Local categories: CategoryItem[] = []
  // 特惠推荐
  @Local saleGoods: GoodsItem[] = []
  // 爆款推荐
  @Local hotGoods: GoodsItem[] = []
  // 一站买全
  @Local oneGoods: GoodsItem[] = []
  // 新鲜好物
  @Local newGoods: GoodsItem[] = []
  // 猜喜推荐
  @Local recommendGoods: GoodsItem[] = []
  breakPointObject?: BreakPoint = AppStorageV2.connect(BreakPoint, () => new BreakPoint())
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  @Local yOffset: number = 0 // scroll滚动列表滚动的偏移量
  @Local searchOpacity: number = 0 // 搜索框透明度
  @Local listPage: number = 1 // 推荐区域页面数量
  @Local isLoading: boolean = false // 是否正在加载 正在请求中
  @Local isFinished: boolean = false // 是否已经加载完成 没有数据了
  promptAction = this.getUIContext().getPromptAction()
  // 推荐列表使用LazyForEach的数据源对象
  // recommendListData = new BasicDataSource<GoodsItem>()
  @Local loadingAnimation: boolean = false // 加载数据动画
  @Local isRefreshing: boolean = false // 是否正在下拉刷新
  @Local indicatorText: string = '' // 下拉刷新指示器文本
  scroller: Scroller = new Scroller() // 用于整体列表滚动控制器

  /**
   * 获取首页数据
   */
  async getHomepageData(showLoading: boolean = true) {
    this.loadingAnimation = showLoading
    const result = await Promise.allSettled([getBannerDataApi(), getCategoryApi(), getHotResultApi(), getInVogueApi(), getOneStopApi(), getNewGoodsApi()])
    const handlers = [
      (value: Banner[]) => (this.banners = value),
      (value: CategoryItem[]) => (this.categories = value),
      (value: HotResult) => (this.saleGoods = value?.subTypes?.[0]?.goodsItems?.items ?? []),
      (value: HotResult) => (this.hotGoods = value?.subTypes?.[0]?.goodsItems?.items ?? []),
      (value: HotResult) => (this.oneGoods = value?.subTypes?.[0]?.goodsItems?.items ?? []),
      (value: GoodsItem[]) => (this.newGoods = value)
    ]
    result.forEach((item, index) => {
      if (item.status == 'fulfilled') {
        handlers[index]?.(item.value as ESObject)
      }
    })
    this.loadingAnimation = false
    // this.banners = await getBannerDataApi()
    // this.categories = await getCategoryApi()
    // const hotResultData = await getHotResultApi()
    // this.saleGoods = hotResultData.subTypes?.[0]?.goodsItems.items ?? []
    // const inVogueData = await getInVogueApi()
    // this.hotGoods = inVogueData.subTypes?.[0]?.goodsItems.items ?? []
    // const oneStopData = await getOneStopApi()
    // this.oneGoods = oneStopData.subTypes?.[0]?.goodsItems.items ?? []
    // this.newGoods = await getNewGoodsApi()
    // this.recommendGoods = new Array(8).fill({
    //   "id": "4033959",
    //   "name": "3秒快速拆琴轻松保养odin奥丁12半音阶口琴",
    //   "price": 329,
    //   "picture": "https://yanxuan-item.nosdn.127.net/937a8e46a9284e8f7e00e13911ecfbe7.png",
    //   "payCount": 0
    // })
  }

  getSpaceValue() {
    return new BreakPointType({
      sm: 14,
      md: 36,
      lg: 72
    }).getValue(this.breakPointObject?.breakPoint ?? BreakPointEnum.SM)
  }

  async getRecommendListData() {
    const list = await getRecommendApi({
      limit: this.listPage * 10
    })
    // Logger.info('page=', this.listPage, 'length=', list.length)
    // 请求十条数据 返回10条 认为还有数据 如果<10条 认为请求完毕了
    if (list.length == this.listPage * 10) {
      this.listPage++
    } else {
      this.isFinished = true
      this.promptAction.showToast({message: "没有更多数据了"})
    }
    // this.recommendGoods.push(...list)
    // this.recommendListData.reloadDataFromNewArray(list)
    this.recommendGoods = list
  }

  aboutToAppear(): void {
    this.getHomepageData()
    this.getRecommendListData()
  }

  @Builder DiscountBuilder(params: Params) {
    Column() {
      Row({ space: 10 }) {
        Text(params.title)
          .fontColor($r('app.color.black'))
          .fontSize(14)
        Text(params.subTitle)
          .fontColor($r('app.color.text'))
          .fontSize(11)
      }
      .width('100%')
      .margin({ bottom: 10 })

      List({ space: 10 }) {
        ForEach(params.list, (item: GoodsItem) => {
          ListItem() {
            DiscountGoods({ type: DiscountType.DISCOUNT, goods: item })
          }
        })
      }
      .width('100%')
      .height(116)
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
    }
    .height(160)
    .layoutWeight(1)
    .padding(10)
    .backgroundColor(params.bg)
    .borderRadius(8)
  }

  @Builder getRefreshIndicator() {
    Row({ space: 10 }) {
      Text(this.indicatorText)
        .fontSize(12)
      ProgressLoading({
        progressWidth: 20,
        strokeWidth: 2,
        color: $r('app.color.black')
      })
    }
    .width('100%')
    .height(60)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    if (!!this.loadingAnimation) {
      LoadingAnimator()
    } else {
      Refresh({ refreshing: this.isRefreshing!!, builder: this.getRefreshIndicator() }) {
        Stack({alignContent: Alignment.Top}) {
          // 主滚动列表
          Scroll(this.scroller) {
            Column() {
              // 轮播图 + 搜索
              Stack({ alignContent: Alignment.Top }) {
                Swiper() {
                  ForEach(this.banners, (item: Banner) => {
                    Image(item.imgUrl)
                  })
                }
                .displayCount(
                  new BreakPointType({
                    sm: 1,
                    md: 2,
                    lg: 3
                  }).getValue(this.breakPointObject?.breakPoint ?? BreakPointEnum.SM)
                )
                .itemSpace(
                  new BreakPointType({
                    sm: 0,
                    md: 10,
                    lg: 20
                  }).getValue(this.breakPointObject?.breakPoint ?? BreakPointEnum.SM)
                )
                .indicator(
                  this.breakPointObject?.breakPoint == BreakPointEnum.SM ?
                    DotIndicator.dot()
                      .itemWidth(8)
                      .itemHeight(4)
                      .color('#33191919')
                      .selectedItemWidth(24)
                      .selectedItemHeight(4)
                      .selectedColor('#191919') : false
                )

                Row() {
                  Row({ space: 4 }) {
                    Image($r('app.media.ic_public_search'))
                      .width(16)
                      .height(16)
                      .fillColor($r('app.color.white'))
                    Text('搜索...')
                      .fontSize(14)
                      .fontColor($r('app.color.white'))
                  }
                  .backgroundColor('#33191919')
                  .width('100%')
                  .height(40)
                  .borderRadius(20)
                  .padding({ left: 12 })
                }
                .padding({ left: 16, right: 16, top: this.safeAreaValue?.topHeight })
              }
              .width('100%')


              // 分类
              Column({ space: 10 }) {
                // 小分类
                List({ space: this.getSpaceValue()}) {
                  ForEach(this.categories, (item: CategoryItem) => {
                    ListItem() {
                      Column() {
                        Image(item.picture)
                          .width(56)
                          .aspectRatio(1)
                        Text(item.name)
                          .fontSize(10)
                          .fontColor('#CC191919')
                      }
                      .width(60)
                      .height(80)
                      .borderRadius(30)

                      .clip(true)
                      .backgroundImage(item.picture)
                      .backgroundImageSize(ImageSize.Contain)
                      .backgroundImagePosition(Alignment.Center)
                      .backgroundBlurStyle(
                        BlurStyle.BACKGROUND_ULTRA_THICK,
                        { scale: 0.25 }
                      )
                    }
                  })
                }
                .width('100%')
                .height(92)
                .scrollBar(BarState.Off)
                .listDirection(Axis.Horizontal)
                .alignListItem(ListItemAlign.Center)

                // 特惠推荐
                Column({ space: 10 }) {
                  Image($r('app.media.home_cmd_title'))
                    .width(150)
                    .height(20)
                  Row() {
                    Image($r('app.media.home_cmd_inner'))
                      .width(86)
                      .height(116)
                    List({ space: this.getSpaceValue()}) {
                      ForEach(this.saleGoods, (item: GoodsItem) => {
                        ListItem() {
                          DiscountGoods({ goods: item })
                        }
                      })
                    }
                    .layoutWeight(1)
                    .width('100%')
                    .height(116)
                    .backgroundColor($r('app.color.white'))
                    .borderRadius({
                      topRight: 8,
                      bottomRight: 8
                    })
                    .padding({ right: 10, left: 10 })
                    .scrollBar(BarState.Off)
                    .listDirection(Axis.Horizontal)
                  }
                }
                .width('100%')
                .height(166)
                .backgroundImage($r('app.media.home_cmd_sm'))
                .backgroundImageSize(ImageSize.Cover)
                .borderRadius(8)
                .padding(10)
                .alignItems(HorizontalAlign.Start)

                // 爆款推荐+一站买全
                Row({ space: 10 }) {
                  this.DiscountBuilder({
                    title: '爆款推荐',
                    subTitle: '最受欢迎',
                    bg: '#EDF1FB',
                    list: this.hotGoods
                  })
                  this.DiscountBuilder({
                    title: '一站买全',
                    subTitle: '精心优选',
                    bg: '#FCF6EA',
                    list: this.oneGoods
                  })
                }

                // 新鲜好物
                Column({ space: 10 }) {
                  Image($r('app.media.home_new'))
                    .width(146)
                    .height(19)
                  List({ space: this.getSpaceValue()}) {
                    ForEach(this.newGoods, (item: GoodsItem) => {
                      ListItem() {
                        DiscountGoods({ type: DiscountType.NEW, goods: item })
                      }
                    })
                  }
                  .width('100%')
                  .height(116)
                  .scrollBar(BarState.Off)
                  .listDirection(Axis.Horizontal)
                }
                .width('100%')
                .height(156)
                .padding(10)
                .backgroundColor('#F7EFF5')
                .borderRadius(8)
                .alignItems(HorizontalAlign.Start)

                // 猜喜
                WaterFlow() {
                  // ForEach(this.recommendGoods, (item: GoodsItem) => {
                  // LazyForEach(this.recommendListData, (item: GoodsItem) => {
                  Repeat(this.recommendGoods).each((object: RepeatItem<GoodsItem>)=> {
                    FlowItem() {
                      Goods({ goods: object.item })
                    }
                  }).virtualScroll({totalCount: this.recommendGoods.length, reusable:true})
                    .key((item, index)=> `${index}_${JSON.stringify(item)}`)
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
              }
              .padding({
                left: 8,
                right: 8,
                bottom: 10,
                top: 10
              })
            }
          }
          .scrollBar(BarState.Off)
          .onDidScroll((_: number, yOffset: number) => {
            this.yOffset += yOffset
            Logger.info(this.yOffset)
            if (!!this.safeAreaValue) {
              if (this.yOffset < this.safeAreaValue?.topHeight) {
                // 几乎没有什么滚动
                this.searchOpacity = 0
              } else if (this.yOffset >= this.safeAreaValue?.topHeight && this.yOffset < this.safeAreaValue?.topHeight + 40) {
                // 当滚动距离大于等于安全区高度且小于安全区高度加搜索框高度时 透明度由0到1渐变
                this.searchOpacity = (this.yOffset - this.safeAreaValue?.topHeight) / 40
              } else {
                this.searchOpacity = 1
              }
            }
          })
          .onReachEnd(async ()=>{
            if (!this.isLoading && !this.isFinished) {
              this.isLoading = true // 上车先把车门焊死
              await this.getRecommendListData()
              this.isLoading = false // 把门打开
            }
          })

          // 搜索吸顶组件
          Row() {
            Row({ space: 4 }) {
              Image($r('app.media.ic_public_search'))
                .width(16)
                .height(16)
                .fillColor($r('app.color.white'))
              Text('搜索...')
                .fontSize(14)
                .fontColor($r('app.color.white'))
            }
            .backgroundColor('#33999797')
            .width('100%')
            .height(40)
            .borderRadius(20)
            .padding({ left: 12 })
          }
          .opacity(this.searchOpacity)
          .padding({
            left: 16,
            right: 16,
            top: this.safeAreaValue?.topHeight,
            bottom: this.safeAreaValue?.topHeight,
          })
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [["#ff949dec", 0], ["#fff", 1]]
          })

          Image($r('app.media.ic_public_top'))
            .width(50)
            .padding(10)
            .backgroundColor($r('app.color.white'))
            .borderRadius(25)
            .opacity(this.searchOpacity)
            .position({
              right: 20,
              bottom: 20
            })
            .onClick(() => this.scroller.scrollEdge(Edge.Top))
        }
      }
      .onRefreshing(async () => {
        this.listPage = 1 // 重置首页推荐列表为起始值
        this.isFinished = false // 防止请求完成后没有更多数据
        // 重新请求数据
        await this.getHomepageData(false)
        await this.getRecommendListData()
        SoundPool.getInstance().play(getContext(this), Constants.HOMEPAGE_MODULE_NAME, Constants.REFRESH_PROMPT_SOUND)
        this.isRefreshing = false // 请求完成便于下次请求
      })
      .onStateChange((state) => {
        switch (state) {
          case RefreshStatus.Inactive:
            this.indicatorText = '下拉刷新'
            break;
          case RefreshStatus.Drag:
            this.indicatorText = '继续下拉'
            break;
          case RefreshStatus.OverDrag:
            this.indicatorText = '松手刷新'
            break;
          case RefreshStatus.Refresh:
            this.indicatorText = '正在刷新'
            break;
          case RefreshStatus.Done:
            this.indicatorText = '刷新完成'
            break;
        }
      })
    }
  }
}