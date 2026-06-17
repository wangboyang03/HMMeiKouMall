import { rcp } from '@kit.RemoteCommunicationKit'
import { Constants } from '../Constants'
import { ResponseData } from '../models'

/**
 * 请求拦截器
 */
class RcpRequestInterceptor implements rcp.Interceptor {
  // 拦截请求
  intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    // context.request.headers?.authorization
    if (typeof context.request.content == "object") {
      // 当请求内容以对象的形式传递时 需要手动去除请求参数字段里的__ob_
      context.request.content = JSON.parse(JSON.stringify(context.request.content).replace(/__ob_/g, "")) as rcp.RequestContent
    }
    return next.handle(context) // 允许放行到下一个执行链
  }
}

/**
 * 响应拦截器
 */
class RcpResponseInterceptor implements rcp.Interceptor {
  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    const res = await next.handle(context)
    return res
  }
}

  const session = rcp.createSession({
    baseAddress: Constants.BASE_URL,
    interceptors: [new RcpRequestInterceptor(), new RcpResponseInterceptor()],
    requestConfiguration: {
      transfer: {
        timeout: {
          connectMs: Constants.TIME_OUT,
          transferMs: Constants.TIME_OUT,
          inactivityMs: Constants.TIME_OUT
        }
      }
    }
  })

export class NetworkRequestUtil {
  static get<T>(url: string, params?: object): Promise<T>{
    return NetworkRequestUtil.transformResponseData<T>(
      session.get(url + '?' + NetworkRequestUtil.paramsToQueryString(params))
    )
  }

  static post<T>(url: string, data?: object): Promise<T> {
    return NetworkRequestUtil.transformResponseData<T>(
      session.post(url, data)
    )
  }

  static put<T>(url:string, data?: object): Promise<T> {
    return NetworkRequestUtil.transformResponseData<T>(
      session.put(url, data)
    )
  }

  static delete<T>(url:string, params?: object, data?: object): Promise<T> | undefined {
    const request = new rcp.Request(url + '?' + NetworkRequestUtil.paramsToQueryString(params), 'DELETE', {}, data)
    return NetworkRequestUtil.transformResponseData<T>(
      session.fetch(request)
    )
  }

  static patch<T>(url:string, data?: object): Promise<T> {
    const request = new rcp.Request(url, 'PATCH', {}, data)
    return NetworkRequestUtil.transformResponseData<T>(
      session.fetch(request)
    )
  }

  /**
   * 请求时可能会携带参数 页面会把请求参数通过对象传递 需要将对象转成能够拼接到url的字符串
   * {name:'1', age:'2'} -> name=1&age=2
   */
  private static paramsToQueryString(params?: object) {
    if (params) {
      return Object.keys(params).filter(key => !!params[key]).map(key => `${key}=${params[key]}`).join('&')
    }
    return ''
  }

  /**
   * 转换接口给回的数据
   */
  private static async transformResponseData<T>(res: Promise<rcp.Response>) {
    // 1.拿到接口给回的数据
    const data = await res
    // 2.转换数据
    const result = data.toJSON() as ResponseData<T>
    if (result.code == Constants.SUCCESS_CODE) {
      return result.result // 请求成功 响应成功
    }
    return Promise.reject(result.message) // 请求成功 响应失败
  }
}