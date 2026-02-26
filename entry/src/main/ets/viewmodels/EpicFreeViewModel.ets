
/// vm
import { EpicFreeModel } from "../models/EpicFreeModel";
import { EpicFreeRepository } from "../repository/EpicFreeRepository";

@Observed
export class EpicFreeViewModel {
  private repository: EpicFreeRepository = new EpicFreeRepository()

  public epicFrees: EpicFreeModel[] = []

  public isLoading: boolean = true

  async loadData(): Promise<void> {
    this.isLoading = true
    this.epicFrees = await this.repository.getEpicFrees()
    this.isLoading = false
  }
}