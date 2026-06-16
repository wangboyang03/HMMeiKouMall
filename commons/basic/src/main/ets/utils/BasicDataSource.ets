export class BasicDataSource<T> implements IDataSource {
  private originalData: T[] = [] // 数据源数组
  private listener: DataChangeListener[] = [] // 监听器数组

  totalCount(): number {
    return this.originalData.length
  }

  getData(index: number): T {
    return this.originalData[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    const index = this.listener.indexOf(listener)
    if (index == -1) {
      // 当前数据不存在监听器数组 需要加入
      this.listener.push(listener)
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index = this.listener.indexOf(listener)
    if (index > -1) {
      // 当前数据存在监听器数组 需要移除
      this.listener.splice(index, 1)
    }
  }

  /**
   * 获取所有数据
   * @returns
   */
  getAllData() {
    return this.originalData
  }

  /**
   * 重新加载数据
   * @param newArray
   */
  reloadDataFromNewArray(newArray: T[]) {
    this.originalData = newArray
    this.listener.forEach(listener => listener.onDataReloaded())
  }

  /**
   * 追加数据
   * @param newArray
   */
  appendDataFromNewArray(newArray: T[]) {
    const index = this.originalData.length
    this.originalData.push(...newArray)
    this.listener.forEach(listener => listener.onDataAdd(index))
  }
}