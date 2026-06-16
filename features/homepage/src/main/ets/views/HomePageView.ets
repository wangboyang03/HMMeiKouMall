import { AppSafeArea, BreakPoint, BreakPointEnum, BreakPointType, CategoryItem, GoodsItem } from "basic"
import { DiscountGoods, Goods } from "../components"
import { Banner, Params, DiscountType } from "../models"
import { AppStorageV2 } from "@kit.ArkUI"
import { getBannerDataApi, getCategoryApi, getHotResultApi, getInVogueApi, getOneStopApi, getNewGoodsApi } from "../api"

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
  // 猜喜
  @Local recommendGoods: GoodsItem[] = []
  breakPointObject?: BreakPoint = AppStorageV2.connect(BreakPoint, () => new BreakPoint())
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())

  // 生成模拟数据
  async getHomepageData() {
    this.banners = await getBannerDataApi()
    this.categories = await getCategoryApi()
    const hotResultData = await getHotResultApi()
    this.saleGoods = hotResultData.subTypes?.[0]?.goodsItems.items ?? []
    const inVogueData = await getInVogueApi()
    this.hotGoods = inVogueData.subTypes?.[0]?.goodsItems.items ?? []
    const oneStopData = await getOneStopApi()
    this.oneGoods = oneStopData.subTypes?.[0]?.goodsItems.items ?? []
    this.newGoods = await getNewGoodsApi()
    this.recommendGoods = new Array(8).fill({
      "id": "4033959",
      "name": "3秒快速拆琴轻松保养odin奥丁12半音阶口琴",
      "price": 329,
      "picture": "https://yanxuan-item.nosdn.127.net/937a8e46a9284e8f7e00e13911ecfbe7.png",
      "payCount": 0
    })
  }

  getSpaceValue() {
    return new BreakPointType({
      sm: 14,
      md: 36,
      lg: 72
    }).getValue(this.breakPointObject?.breakPoint ?? BreakPointEnum.SM)
  }

  aboutToAppear(): void {
    // 获取首页接口数据
    this.getHomepageData()

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

  build() {
    Scroll() {
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
            ForEach(this.recommendGoods, (item: GoodsItem) => {
              FlowItem() {
                Goods({ goods: item })
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
  }
}