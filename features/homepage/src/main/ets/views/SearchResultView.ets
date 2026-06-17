import { HMRouter, HMRouterMgr } from '@hadss/hmrouter'
import { AppSafeArea, BasicDataSource, BreakPoint, BreakPointType, GoodsItem, StackAddress } from 'basic'
import { AppStorageV2 } from '@kit.ArkUI'
import { SearchParams, SearchRouterParam, SortCompAttr, SortField, SortMethod } from '../models'
import { Goods, SearchSortItem } from '../components'


@HMRouter({ pageUrl: StackAddress.SEARCH_RESULT_PAGE })
@ComponentV2
export struct SearchResultView {
  breakPointObject?: BreakPoint = AppStorageV2.connect(BreakPoint, () => new BreakPoint())
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  // 查询数据源
  lazyDataSource: BasicDataSource<GoodsItem> = new BasicDataSource()
  // 查询参数
  params: SearchParams = new SearchParams()
  // 筛选条件
  sortList: SortCompAttr[] = [
    { label: '时间', field: 'publishTime' },
    { label: '销量', field: 'orderNum' },
    { label: '价格', field: 'price' }
  ]
  // 控制器
  scroller = new Scroller()

  aboutToAppear(): void {
    const params = HMRouterMgr.getCurrentParam() as SearchRouterParam
    this.getUIContext().getPromptAction().openToast({message: JSON.stringify(params)})
  }

  build() {
    if (this.breakPointObject) {
      Column() {
        // 搜索区域
        Row() {
          Image($r('app.media.ic_public_left'))
            .width(24)
            .aspectRatio(1)
            .fillColor($r('app.color.white'))
            .margin(13)
            .onClick(() => HMRouterMgr.pop())
          Search({ placeholder: '商品关键字...', value: this.params.keyword!! })
            .searchIcon({ src: $r('app.media.ic_public_search'), color: $r('app.color.gray') })
            .placeholderColor($r('app.color.gray'))
            .placeholderFont({ size: 14 })
            .backgroundColor($r('app.color.white'))
            .textFont({ size: 14 })
            .layoutWeight(1)
            .padding(0)
            .margin(0)
            .height(36)
            .caretStyle({ color: $r('app.color.red') })
            .onSubmit(() => {})
        }
        .padding({ top: this.safeAreaValue?.topHeight, right: 16 })
        .linearGradient({
          angle: 135,
          colors: [[$r('app.color.linear_begin'), 0], [$r('app.color.linear_end'), 1]]
        })

        // 搜索排序
        Row() {
          ForEach(this.sortList, (item: SortCompAttr) => {
            // 筛选组件
            SearchSortItem({
              label: item.label,
              field: item.field,
              sortField: this.params.sortField,
              sortMethod: this.params.sortMethod,
              onSortChange: (field: SortField, method: SortMethod) => {}
            })
          })
          Text('筛选')
            .fontSize(14)
            .fontColor($r('app.color.gray'))
        }
        .padding({ left: 16, right: 16 })
        .height(50)
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .border({ width: { bottom: 0.5 }, color: $r('app.color.border') })

        // 搜索商品列表
        WaterFlow({ scroller: this.scroller }) {
          LazyForEach(this.lazyDataSource, (item: GoodsItem) => {
            FlowItem() {
              Goods({ goods: item, smallImage: true })
            }
          })
        }
        .columnsTemplate(
          new BreakPointType({
            sm: '1fr 1fr',
            md: '1fr 1fr 1fr',
            lg: '1fr 1fr 1fr 1fr'
          }).getValue(this.breakPointObject.breakPoint)
        )
        .columnsGap(0.5)
        .rowsGap(0.5)
        .layoutWeight(1)
        .onReachEnd(async () => {})
      }
    }
  }
}
