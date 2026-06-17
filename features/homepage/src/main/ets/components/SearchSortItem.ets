import { SortField, SortMethod } from "../models"

@ComponentV2
export struct SearchSortItem {
  // 筛选字段
  @Param field: SortField = 'publishTime'
  // 显示的文本
  @Param label: string = ''
  // 状态变量，接收父组件的状态属性
  // 父组件的筛选字段
  @Param sortField: SortField = 'publishTime'
  // 父组件的排序方法
  @Param sortMethod: SortMethod = 'desc'
  // 定义子传父的函数
  @Event onSortChange: (field: SortField, method: SortMethod) => void = () => {}

  build() {
    Row() {
      Text(this.label)
        .fontWeight(500)
        .fontSize(14)
        .fontColor(this.sortField === this.field ? $r('app.color.black') : $r('app.color.gray'))
      Column() {
        Image($r('app.media.ic_public_up'))
          .width(15)
          .height(6)
          .fillColor(this.sortField == this.field && this.sortMethod == 'asc' ? $r('app.color.black') : $r('app.color.gray'))
        Image($r('app.media.ic_public_down'))
          .width(15)
          .height(6)
          .fillColor(this.sortField == this.field && this.sortMethod == 'desc' ? $r('app.color.black') : $r('app.color.gray'))
      }
      .justifyContent(FlexAlign.Center)
    }
    .onClick(() => {})
  }
}