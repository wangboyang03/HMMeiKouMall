import { HMRouter, HMRouterMgr } from '@hadss/hmrouter'
import { AppSafeArea, BasicDataSource, BreakPoint, BreakPointType, GoodsItem, StackAddress } from 'basic'
import { AppStorageV2 } from '@kit.ArkUI'
import { SearchParams, SearchRouterParam, SortCompAttr, SortField, SortMethod } from '../models'
import { Goods, SearchSortItem } from '../components'
import { getSearchResultApi } from '../api'


@HMRouter({ pageUrl: StackAddress.SEARCH_RESULT_PAGE })
@ComponentV2
export struct SearchResultView {
  breakPointObject?: BreakPoint = AppStorageV2.connect(BreakPoint, () => new BreakPoint())
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  // 查询数据源
  // lazyDataSource: BasicDataSource<GoodsItem> = new BasicDataSource()
  @Local goodsList: GoodsItem[] = []
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
  // 触底加载状态变量
  @Local isLoading: boolean = false // 正在加载 中
  @Local isFinished: boolean = false // 是否已经加载完成

  async getSearchResultData() {
    const res = await getSearchResultApi(this.params)
    // 如果使用@ObservedV2+@Trace装饰的对象属性字段会被加上__ob_ 在请求拦截器做统一处理
    // this.lazyDataSource.reloadDataFromNewArray(res.pageData.items)
    // this.goodsList = res.pageData.items
    this.goodsList.push(...res.pageData.items) // 追加数据
    if (this.params.page >= res.pageData.page) {
      // 认为数据已经加载完成
      this.isFinished = true
    } else {
      this.params.page++ // 加载下一页数据
    }
  }

  onChangeGoodsList() {
    this.goodsList = []
    this.params.page = 1
    this.isFinished = false
    this.getSearchResultData() // 重新请求数据
  }

  aboutToAppear(): void {
    const params = HMRouterMgr.getCurrentParam() as SearchRouterParam
    // this.getUIContext().getPromptAction().openToast({message: JSON.stringify(params)})
    this.params.keyword = params.keyword
    this.getSearchResultData()
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
            .onSubmit((_:string) => this.onChangeGoodsList())
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
              onSortChange: (field: SortField, method: SortMethod): void => {
                this.params.sortField = field
                this.params.sortMethod = method
                this.onChangeGoodsList()
              }
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
        WaterFlow({ scroller: this.scroller, footer: this.getFootBuilder() }) {
          // LazyForEach(this.lazyDataSource, (item: GoodsItem) => {
          Repeat(this.goodsList).each((object: RepeatItem<GoodsItem>) => {
            FlowItem() {
              Goods({ goods: object.item, smallImage: true })
            }
          }).virtualScroll() // 开启虚拟滚动
            .key((item: GoodsItem, index: number) => `${index}_${JSON.stringify(item)}`)
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
        .onReachEnd(async () => {
          if (!this.isLoading && !this.isFinished) {
            this.isLoading = true
            await this.getSearchResultData()
            this.isLoading = false
          }
        })
      }
    }
  }

  @Builder getFootBuilder() {
    Row({ space: 10 }) {
      if (this.isLoading) {
        Text("正在加载中...")
          .fontSize(12)
          .fontColor($r("app.color.gray"))
        LoadingProgress()
          .width(20)
          .aspectRatio(1)
      } else {
        if (this.isFinished) {
          Text("没有更多数据。")
            .fontSize(12)
            .fontColor($r("app.color.gray"))
        }
      }
    }
    .justifyContent(FlexAlign.Center)
    .width("100%")
    .height(50)
  }
}
