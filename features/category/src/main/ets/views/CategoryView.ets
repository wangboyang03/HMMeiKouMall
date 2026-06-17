import { HMRouterMgr } from "@hadss/hmrouter"
import { AppStorageV2 } from "@kit.ArkUI"
import { AppCategoryData, AppSafeArea, BreakPoint,
  BreakPointType,
  CategoryItem, CategoryItemChild, NavigationBar,
  StackAddress } from "basic"

@ComponentV2
export struct CategoryView {
  breakPointObject?: BreakPoint = AppStorageV2.connect(BreakPoint, () => new BreakPoint())
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  categories?: CategoryItem[] = AppStorageV2.connect(AppCategoryData, () => new AppCategoryData())?.category
  @Local activeIndex: number = 0

  build() {
    Column() {
      NavigationBar({
        title: '分类',
        showLeftIcon: false,
        showRightIcon: true,
        rightIcon: $r("app.media.ic_public_search"),
        onRightClick: () => HMRouterMgr.push({
          pageUrl: StackAddress.SEARCH_PAGE
        })
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
              .onClick(() => this.activeIndex = index)
            })
        }
        .width(88)
        .border({ width: { right: 0.5 }, color: $r('app.color.under') })

        Scroll() {
          Column() {
            if (!!this.breakPointObject) {
              // 顶部图片
              Image(this.categories?.[this.activeIndex]?.picture)
                .draggable(false) // 禁用拖动到小艺识别
                .width('100%')
                .height(new BreakPointType({
                  sm: 136,
                  md: 316,
                  lg: 316
                }).getValue(this.breakPointObject?.breakPoint))
                .objectFit(ImageFit.Contain)
                .backgroundColor('#f6f6f6')
                .borderRadius(8)
                .margin({ bottom: 8 })
              GridRow({ columns: new BreakPointType({
                sm: 2,
                md: 3,
                lg: 4
              }).getValue(this.breakPointObject.breakPoint),
                gutter: new BreakPointType({
                  sm: 8,
                  md: 12,
                  lg: 14
              }).getValue(this.breakPointObject.breakPoint)}) {
                // 子分类
                ForEach(this.categories?.[this.activeIndex]?.children, (sub: CategoryItemChild) => {
                  GridCol() {
                    Column() {
                      // 图片
                      Image(sub.picture)
                        .draggable(false)
                        .width(64)
                        .aspectRatio(1)
                      Text(sub.name)// 文本
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