import { BreakPointEnum } from "../Constants"

interface BreakPointTypeOption<T> {
  xs?: T
  sm?: T
  md?: T
  lg?: T
  xl?: T
}

export class BreakPointType<T> {
  options: BreakPointTypeOption<T>

  constructor(option: BreakPointTypeOption<T>) {
    this.options = option
  }

  getValue(currentBreakPoint: BreakPointEnum): T {
    /**
     * 输入 断点值 xs,sm,md,lg...
     * 输出 Color.red, Color.yellow, Color.green...
     * 通过将对象转为 Record<BreakPointEnum, T> 类型通过[key]的方式取值
     * 在鸿蒙中只有小写的object和record<>类型才能通过[key]的方式取值
     */
    return (this.options as Record<BreakPointEnum, T>)[currentBreakPoint]
  }
}