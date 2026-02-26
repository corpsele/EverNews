/// 首页
import { CachedImage } from '../common/CacheImage';
import { ImageCacheManager } from '../common/ImageCacheManager';
import { EpicFreeModel } from '../models/EpicFreeModel';
import { EpicFreeViewModel } from '../viewmodels/EpicFreeViewModel';
import { DetailPage } from './DetailPage';

@Entry
@Component
export struct HomePage {
  // 使用 NavPathStack 管理二级导航
  private navStack: NavPathStack = new NavPathStack()
  @State private viewModel: EpicFreeViewModel = new EpicFreeViewModel()
  private manager: ImageCacheManager = ImageCacheManager.getInstance();

  aboutToAppear() {
    this.viewModel.loadData()

  }
  build() {
    // Navigation 组件负责导航栏和页面路由
    Navigation(this.navStack) {
      Column() {
        if (this.viewModel.isLoading) {
          LoadingProgress().margin({ top: 100 })
        } else {
          List({ space: 12 }) {
            ForEach(this.viewModel.epicFrees, (item: EpicFreeModel) => {

              ListItem() {
                this.EpicFreeItemBuilder(item)
              }
              .onClick(() => {
                // 点击跳转二级页面，传递参数
                // this.navStack.pushPath({ name: 'DetailPage', param: item });
                this.navStack.pushPathByName('DetailPage', item)
              })
            }, (item: EpicFreeModel) => item.id.toString())
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 12, right: 12 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .title('首页资讯') // 导航标题
    .titleMode(NavigationTitleMode.Free)
    .mode(NavigationMode.Stack)
    .navDestination(this.buildNavDestination) // 注册二级页面路由
  }

  @Builder
  buildNavDestination(name: string, param: EpicFreeModel) {
    if (name === 'DetailPage') {
      DetailPage(
        {
          epicFree: param
        }
      )
    }
  }

  @Builder
  EpicFreeItemBuilder(item: EpicFreeModel) {
    Row() {
      Column() {
        CachedImage(
          {
            imgSrc: item.cover,
            objectFit: ImageFit.Contain
          }
        )
          .width(120)
          .height(120)
          .padding(20)
      }
      Column() {
        Text(item.title)
          .fontSize(16)
          .fontWeight(500)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(`简介: ${item.description}`)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ top: 6 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }

}