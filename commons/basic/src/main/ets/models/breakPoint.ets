import { BreakPointEnum } from "../Constants";


@ObservedV2 export class BreakPoint {
  @Trace breakPoint: BreakPointEnum = BreakPointEnum.SM
}