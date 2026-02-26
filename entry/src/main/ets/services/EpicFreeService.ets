import { Constants } from '../common/Constants'
import { HttpUtil } from '../common/HttpUtil'
import { EpicFreeModel } from '../models/EpicFreeModel'

/// 请求接口 网络层


interface EpicFreeResponse {
  message: string
  data: EpicFreeModel[]
  // errorCode: number
  code: string
}

export class EpicFreeService {
  async fetchEpicFrees(): Promise<EpicFreeModel[]> {
    try {
      const response = await HttpUtil.get<EpicFreeResponse>(Constants.EPIC_URL)
      if (!response.code) {
        console.info(`[EpicFreeService] response.data = ${response.data}, response.data.datas = ${response.data}`)
        return response.data
      } else {
        return []
      }
    } catch (err) {
      console.error('[Service] Network error: ', err)
      return []
    }
  }
}