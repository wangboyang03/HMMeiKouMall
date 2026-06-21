@Preview
@Component
export struct AddressItem {
  province: string = 'A省'
  city: string = 'B市'
  address: string = 'C区'
  name: string = '姓名'
  phone: string = '1234567890'
  tag: string = '默认'

  build() {
    RelativeContainer() {
      Text(`${this.province}${this.city}`)
        .id('cityText')
        .alignRules({
          top: {anchor: '__container__', align: VerticalAlign.Top},
          left: {anchor: '__container__', align: HorizontalAlign.Start }
        })

      Text(this.address)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .id('address')
        .alignRules({
          center: {anchor: '__container__', align: VerticalAlign.Center}
        })

      Text() {
        Span(this.name)
          .padding({
            right: 5
          })
        Span(this.phone)
      }
        .fontSize(16)
        .id('person')
        .alignRules({
          top: {anchor: 'address', align: VerticalAlign.Bottom},
          left: {anchor: '__container__', align: HorizontalAlign.Start}
        })

      Text(this.tag)
        .padding({
          top: 3,
          right: 6,
          bottom: 3,
          left: 6
        })
        .border({
          width: 1,
          radius: 4
        })
        .alignRules({
          left: {anchor: 'person', align: HorizontalAlign.End},
          center: {anchor: 'person', align: VerticalAlign.Center}
        })

      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(20)
        .height(20)
        .alignRules({
          right: {anchor: '__container__', align: HorizontalAlign.End },
          center: {anchor: '__container__', align: VerticalAlign.Center }
        })
    }
    .width('100%')
    .height(120)
    .padding(16)
  }
}