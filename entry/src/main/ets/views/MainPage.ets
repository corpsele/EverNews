/// 主页

import { HomePage } from './HomePage'
import { DiscoverPage } from './DiscoverPage'
import { MessagePage } from './MessagePage'
import { ProfilePage } from './ProfilePage'

@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0;
  build() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        HomePage()
      }.tabBar(this.TabBuilder(0, '首页', $r('sys.symbol.house')))
      TabContent() {
        DiscoverPage()
      }.tabBar(this.TabBuilder(1, '发现', $r('sys.symbol.compass')))
      TabContent() {
        MessagePage()
      }.tabBar(this.TabBuilder(2, '消息', $r('sys.symbol.message')))
      TabContent() {
        ProfilePage()
      }.tabBar(this.TabBuilder(3, '我的', $r('sys.symbol.person')))
    }
    .barHeight(56)
    .barBackgroundColor(Color.White)
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .width('100%')
    .height('100%')
  }
  @Builder
  TabBuilder(index: number, title: string, icon: Resource) {
    Column() {
      SymbolGlyph(icon)
        .fontSize(22)
        .fontColor([this.currentIndex === index ? '#007DFF' : '#999999'])

      Text(title)
        .fontSize(12)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#999999')
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}