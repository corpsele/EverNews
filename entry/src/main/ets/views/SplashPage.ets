
/// 欢迎页

@Entry
@Component
struct SplashPage {
  build() {
    Column() {
      Image('app.media.startIcon')
        .width(120)
        .height(120)
        .margin(
          {
            bottom: 20
          }
        )

      Text('EverNews')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Text('Entertainment And Games News')
        .fontSize(14)
        .fontColor('#333333')
        .margin(
          {
            top: 10
          }
        )
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#007DFF')
  }
}