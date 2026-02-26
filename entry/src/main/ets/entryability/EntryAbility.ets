import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { DatabaseManager } from '../common/DatabaseManager';
import { ImageCacheManager } from '../common/ImageCacheManager';
import { ImageLoader } from '../common/ImageLoader';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    // 初始化数据库，必须传入 context
    await DatabaseManager.getInstance().init(this.context);
    ImageCacheManager.getInstance().init(this.context);
    // 初始化图片加载器的磁盘缓存路径
    ImageLoader.getInstance().initDiskCache(this.context);
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // windowStage.loadContent('pages/Index', (err) => {
    //   if (err.code) {
    //     hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
    //     return;
    //   }
    //   hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    // });
    // 1. 加载欢迎页
    windowStage.loadContent('views/SplashPage', (err, data) => {
      if (err.code) {
        console.error('Failed to load the content. Cause:', JSON.stringify(err));
        return;
      }

      // 2. 模拟2秒后跳转主页面
      setTimeout(() => {
        windowStage.loadContent('views/MainPage', (err, data) => {
          // 此时 SplashPage 被替换为 MainPage
        });
      }, 2000);
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}