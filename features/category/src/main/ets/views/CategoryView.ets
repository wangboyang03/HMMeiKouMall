import { AppStorageV2 } from "@kit.ArkUI"
import { AppSafeArea, BreakPoint, CategoryItem, CategoryItemChild, NavigationBar } from "basic"

@ComponentV2
export struct CategoryView {
  breakPointObject?: BreakPoint = AppStorageV2.connect(BreakPoint, () => new BreakPoint())
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  //  Mock分类数据
  categories: CategoryItem[] = new Array(10).fill({
    id: "1181622001",
    name: "气质女装",
    picture: "https://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/meikou/c1/qznz.png"
  })
  @Local activeIndex: number = 0

  build() {
    Column() {
      NavigationBar({
        title: '分类',
        showLeftIcon: false,
        showRightIcon: true,
        rightIcon: $r("app.media.ic_public_search")
      })
      Row() {
        Column() {
          ForEach(this.categories, (item: CategoryItem, index) => {
            Text(item.name)// 文本
              .backgroundColor(this.activeIndex == index ? $r('app.color.black') : $r('app.color.white'))
              .fontSize(14)
              .fontColor(this.activeIndex == index ? $r('app.color.white') : $r('app.color.black'))
              .textAlign(TextAlign.Center)
              .width('100%')
              .height(56)
              .fontColor(this.activeIndex == index ? $r('app.color.white') : $r('app.color.black'))
            })
        }
        .width(88)
        .border({ width: { right: 0.5 }, color: $r('app.color.under') })

        Scroll() {
          Column() {
            // 顶部图片
            Image('https://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/meikou/c1/qznz.png')
              .width('100%')
              .height(136)
              .objectFit(ImageFit.Contain)
              .backgroundColor('#f6f6f6')
              .borderRadius(8)
              .margin({ bottom: 8 })
            GridRow({ columns: 2, gutter: 8 }) {
              // 子分类
              ForEach(Array.from({ length: 10 }), (sub: CategoryItemChild) => {
                GridCol() {
                  Column() {
                    // 图片
                    Image('https://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/meikou/c2/qznz_bq.png?quality=95&imageView')
                      .width(64)
                      .aspectRatio(1)
                    Text('半裙')// 文本
                      .fontSize(14)
                      .fontColor($r('app.color.text'))
                      .margin({ top: 8 })
                  }
                  .height('100%')
                  .justifyContent(FlexAlign.Center)
                }
                .aspectRatio(1)
                .backgroundColor('#f6f6f6')
                .borderRadius(8)
              })
            }
          }
          .padding(8)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .height('100%')
  }
}