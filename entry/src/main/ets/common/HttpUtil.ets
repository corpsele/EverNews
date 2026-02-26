
/// 网络请求封装

import http from '@ohos.net.http';
import { Constants } from './Constants'

export class HttpUtil {
  static async get<T>(endporint: string): Promise<T> {
    const httpRequest = http.createHttp()
    let result: string = ""
    try {
      console.info(`url = ${Constants.EPIC_URL + endporint}`)
      const response = await httpRequest.request(endporint, {
        method: http.RequestMethod.GET,
        // header: { 'Content-Type': 'application/json' },
        connectTimeout: 60000,
        readTimeout: 60000
      })

      if (response.responseCode == 200) {
        result = JSON.parse(response.result as string)
        return result as T
      } else {
        const err = new Error(`HTTP Error ${response.responseCode}`)
        throw err
      }
    } catch (err) {
      console.error(`HttpUtil get error = ${JSON.stringify(err)}`)
      return result as T
    } finally {
      httpRequest.destroy()
      // return result as T
    }
  }
}