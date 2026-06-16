@Component
export struct ProgressLoading {
  @Prop progressWidth: number = 80 // 组件宽度
  @Prop strokeWidth: number = 10 // 圆环宽度
  @Prop color: ResourceColor = $r('app.color.red') // 进度值色值
  @State currentValue: number = 40 // 当前进度 40->80, 80->40
  @State isClockwise: boolean = false // 是否顺时针运行
  @State rotateAngle: number = 0 // 旋转角度
  timer?: number

  aboutToAppear(): void {
    this.timer = setInterval(()=> {
      // 1.边界判断
      if (this.currentValue == 80) {
        this.isClockwise = false // 正着过去就要倒着回去
      }
      if (this.currentValue == 40) {
        this.isClockwise = true // 倒着过去就要正着回去
      }
      if (this.isClockwise) {
        this.currentValue++
      } else {
        this.currentValue--
      }
    }, 100)
  }

  aboutToDisappear(): void {
    clearInterval(this.timer)
  }

  build() {
    Progress({
      type: ProgressType.Ring,
      value: this.currentValue,
      total: 100,
    })
      .width(this.progressWidth)
      .aspectRatio(1)
      .color(this.color)
      .style({
        strokeWidth: this.strokeWidth
      })
      .rotate({
        angle: this.rotateAngle
      })
      .onAppear(()=> animateTo({
        iterations: -1,
        duration: 1000,
      }, ()=> this.rotateAngle = 360))
  }
}