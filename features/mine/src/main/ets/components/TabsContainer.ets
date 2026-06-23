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