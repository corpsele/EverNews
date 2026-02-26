
/// 业务层
import { DatabaseManager } from "../common/DatabaseManager";
import { EpicFreeModel } from "../models/EpicFreeModel";
import { EpicFreeService } from "../services/EpicFreeService";

export class EpicFreeRepository {
  private service: EpicFreeService = new EpicFreeService()

  async getEpicFrees(): Promise<EpicFreeModel[]> {
    // 请求网络
    const epicData = await this.service.fetchEpicFrees()
    if (epicData.length > 0) {
      // 请求成功存入本地并返回
      console.info("[Repository] Save to DB")
      await DatabaseManager.getInstance().saveEpicFree(epicData)
      return epicData
    } else {
      // 请求失败读取本地
      console.info('[Repository] Load from DB cache')
      const epicFrees = await DatabaseManager.getInstance().getLocalEpicFree()
      return epicFrees
    }
  }
}