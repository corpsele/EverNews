/// 首页二级页面
import { EpicFreeModel } from "../models/EpicFreeModel";

@Entry
@Component
export struct DetailPage {
  // 接收上一页传递的参数
  @Prop epicFree: EpicFreeModel = {
    id: "1",
    title: "初始化",
    cover: "",
    description: "",
    original_price: 0,
    original_price_desc: "",
    seller: "",
    is_free_now: false,
    free_start: "",
    free_start_at: 0,
    free_end: "",
    free_end_at: 0,
    link: ""
  };

  build() {
    Navigation() {
      Column() {
        Text(this.epicFree.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .padding(20)

        Divider()

        Text(this.epicFree.link)
          .fontSize(14)
          .fontColor('#007DFF')
          .padding(20)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)

    }
    .title('详情页') // 二级页面标题
    .titleMode(NavigationTitleMode.Mini)
  }
}