import { application } from "@kit.AbilityKit"
import { Constants } from "../Constants"
import { util } from "@kit.ArkTS"

// 1.读取rawfile文件的数据结构
export interface AreaDataItem {
  code: string
  name: string
  areaList: AreaDataItem[]
}

// 2.定义h5侧需要的数据类型
export interface LocationData {
  province_list: Record<number, string>
  city_list: Record<number, string>
  county_list: Record<number, string>
}

export class LocationPlugin {
  private static sInstance: LocationPlugin
  private constructor() {} // 私有构造函数

  /**
   * 获取单例实例
   * @returns
   */
  public static getInstance(): LocationPlugin {
    if (!LocationPlugin.sInstance) {
      LocationPlugin.sInstance = new LocationPlugin()
    }
    return LocationPlugin.sInstance
  }

  async getLocationData(context: Context) {
    // 1. 装载rawfile文件数据的数组
    const locationDataList: LocationData = {
      province_list: {},
      city_list: {},
      county_list: {}
    }

    try {
      // 2.读取文件
      const basicContext = await application.createModuleContext(context, Constants.BASIC_MODULE_NAME)
      const uni8Array = await basicContext.resourceManager.getRawFileContent("area.json")
      const decoder = new util.TextDecoder() // 创建解码器
      const res = decoder.decodeToString(uni8Array) // 解码

      // 3.遍历文件数据 分别取出省市区重新装入集合中
      const areaData = JSON.parse(res) as AreaDataItem[]
      areaData.forEach((province) => {
        locationDataList.province_list[Number(province.code)] = province.name
        province.areaList.forEach((city) => {
          locationDataList.city_list[Number(city.code)] = city.name
          city.areaList.forEach((county) => {
            locationDataList.county_list[Number(county.code)] = county.name
          })
        })
      })
      return locationDataList
    } catch (error) {
      return locationDataList
    }
  }
}