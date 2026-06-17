import { CategoryItem } from "."
import { BreakPointEnum } from "../Constants"

@ObservedV2 export class BreakPoint {
  @Trace breakPoint: BreakPointEnum = BreakPointEnum.SM
}

@ObservedV2 export class AppSafeArea {
  @Trace topHeight: number = 0
  @Trace bottomHeight: number = 0
}

@ObservedV2 export class AppCategoryData {
  @Trace category: CategoryItem[] = []
}