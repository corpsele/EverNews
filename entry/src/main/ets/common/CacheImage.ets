/// 图片view封装

// CachedImage.ets
import { ImageLoader } from './ImageLoader';
import image from '@ohos.multimedia.image';

@Component
export struct CachedImage {
  @Prop imgSrc: string = ''; // 图片URL
  @State pixelMap: image.PixelMap | null = null;
  @State isLoading: boolean = true;
  @State hasError: boolean = false;
  @State objectFit: ImageFit = ImageFit.Auto;

  aboutToAppear() {
    this.loadImage();
  }

  // 如果组件复用，URL发生变化时需要重新加载
  aboutToUpdate() {
    // 简单的判断逻辑，实际项目中可能需要深度比较
    // 注意：aboutToUpdate 在状态变量变更时触发，需注意避免死循环
  }

  async loadImage() {
    if (!this.imgSrc) return;

    this.isLoading = true;
    this.hasError = false;

    const loader = ImageLoader.getInstance();
    const result = await loader.loadImage(this.imgSrc);

    if (result) {
      this.pixelMap = result;
      this.hasError = false;
    } else {
      this.hasError = true;
    }
    this.isLoading = false;
  }

  build() {
    Stack() {
      if (this.isLoading) {
        // 加载中占位图
        LoadingProgress()
          .width(40)
          .height(40)
          .color(Color.Gray)
      } else if (this.hasError) {
        // 加载失败占位图
        Image($r('app.media.layered_image')) // 请确保资源存在
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)
      } else if (this.pixelMap) {
        // 显示图片
        Image(this.pixelMap)
          .width('100%')
          .height('100%')
          .objectFit(this.objectFit)
      }
    }
    .width('100%')
    .height('100%')
  }
}
