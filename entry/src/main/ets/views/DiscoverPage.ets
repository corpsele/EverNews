@Entry
@Component
export struct DiscoverPage {
  private navStack: NavPathStack = new NavPathStack();
  build() {
    Navigation(this.navStack) {
      Column() {
        Text('发现页面')
          .fontSize(20)

        Button('进入二级页面')
          .margin({ top: 20 })
          .onClick(() => {
            // 模拟跳转
            // this.navStack.pushPath(...);
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .title('发现')
    .titleMode(NavigationTitleMode.Free)
  }
}