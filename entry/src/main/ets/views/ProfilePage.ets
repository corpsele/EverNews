
@Entry
@Component
export struct ProfilePage {
  private navStack: NavPathStack = new NavPathStack();
  build() {
    Navigation(this.navStack) {
      Column() {
        Text('我的页面')
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
    .title('我的')
    .titleMode(NavigationTitleMode.Free)
  }
}