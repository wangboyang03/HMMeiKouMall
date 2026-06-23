import { Logger } from "basic"

interface OrderType {
  id: number
  label: string
}

@ComponentV2
export struct TabsContainer {
  @Param @Once activeIndex:number = 0
  @Local orderTypeList: OrderType[] = [
    {id: 1, label: '全部'},
    {id: 2, label: '待付款'},
    {id: 3, label: '待发货'},
    {id: 4, label: '待收货'},
    {id: 5, label: '待评价'},
  ]
  @Event onTabChange: (index: number) => void

  build() {
    Tabs({index: $$this.activeIndex}) {
      ForEach(this.orderTypeList, (item: OrderType, index) => {
        TabContent()
          .tabBar(this.TabBarBuilder(item, index))
      })
    }
    .width('100%')
    .barMode(BarMode.Scrollable)
    .barHeight(44)
    .scrollable(false)
    .backgroundColor($r('app.color.white'))
    .divider({ strokeWidth: 0.5, color: $r('app.color.under') })
    .onTabBarClick(index => {
      this.activeIndex = index
      this.onTabChange(this.activeIndex)
    })
  }

  @Builder TabBarBuilder(item: OrderType, i: number) {
    Row() {
      Stack({ alignContent: Alignment.Bottom }){
        Text(item.label)
          .fontSize(15)
          .fontColor(this.activeIndex == i ? $r('app.color.black') : $r('app.color.gray'))
          .height(44)
          .margin({
            bottom: 5
          })
        Text()
          .width(this.activeIndex == i ? 10 : 0)
          .height(2)
          .backgroundColor($r('app.color.black'))
          .animation({ duration: this.activeIndex == i ? 300 : 0 })
      }
    }
    .padding({ left: 16, right: this.orderTypeList.length == i + 1 ? 16 : 0 })
    .layoutWeight(1)
    .justifyContent(FlexAlign.SpaceEvenly)
  }
}

@ComponentV2
export struct CustomTabs {
  @Param @Once
  activeIndex: number = 0
  @Param tabConfig: OrderType[] = []
  @Param @Once lineWidth: number = 20
  @Param lineHeight: number = 2
  @Param tabHeight: number = 40
  @Param gutter: number = 20
  @Param paddingLeft: number = this.gutter
  @Param paddingRight: number = this.gutter
  @Local left: number = 0
  @Event onTabClick?: (tab: OrderType, index: number) => void
  @Event onTabChange?: (tab: OrderType, index: number) => void
  list: Area[] = []
  @Param spaceBetween: boolean = false

  // 设置线位置
  setLineLeft(area: Area) {
    // 先拿到每一个Item的宽度
    const width = area.width as number
    // 再拿到线条的位置
    const x = area.position.x as number
    this.left = x + (width - this.lineWidth) / 2
  }

  @Monitor('activeIndex')
  onActiveIndexChange(monitor: IMonitor) {
    this.setLineLeft(this.list?.[this.activeIndex])
  }

  build() {
    Row() {
      Row({ space: this.gutter }) {
        ForEach(this.tabConfig, (item: OrderType, index) => {
          this.TabBuilder(item, index)
        })
      }
      .width('100%')
      .padding({ left: this.paddingLeft, right: this.paddingRight })
      .height(this.tabHeight)
      .border({
        width: { bottom: 0.5 },
        color: $r('app.color.under')
      })
      .justifyContent(this.spaceBetween ? FlexAlign.SpaceBetween : FlexAlign.Start)

      // 移动的文本
      Text()
        .width(this.lineWidth)
        .height(this.lineHeight)
        .backgroundColor($r('app.color.black'))
        .position({ x: this.left, y: this.tabHeight - this.lineHeight })
        .animation({ duration: 300 })
    }
    .layoutWeight(1)
    .backgroundColor($r('app.color.white'))
  }

  @Builder TabBuilder(tab: OrderType, index: number) {
    Text(tab.label)
      .fontSize(15)
      .fontColor(this.activeIndex === index ? $r('app.color.black') : $r('app.color.gray'))
      .fontWeight(this.activeIndex === index ? 500 : 400)
      .animation({
        duration: 300
      })
      .onClick((e) => {
        if (this.activeIndex != index) {
          this.activeIndex = index
          this.onTabChange && this.onTabChange(tab, index)
        }
        this.onTabClick && this.onTabClick(tab, index)
      })
      .onAreaChange((oldValue, newValue) => {
        this.list[index] = newValue // 获取每一个TabItem的区域变化后的信息
        Logger.info(this.list)
        if (this.activeIndex == index) {
          this.setLineLeft(this.list?.[this.activeIndex])
        }
      })
  }
}