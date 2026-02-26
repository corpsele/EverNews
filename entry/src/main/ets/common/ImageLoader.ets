/// 图片缓存封装

// ImageLoader.ets
import http from '@ohos.net.http';
import fs from '@ohos.file.fs';
import image from '@ohos.multimedia.image';
import util from '@ohos.util';
import common from '@ohos.app.ability.common';
import { HashCodeUtil } from './HashCodeUtil'

// 缓存配置
const MEMORY_CACHE_SIZE = 100; // 内存缓存最大数量
const DISK_CACHE_DIR = 'image_cache'; // 磁盘缓存文件夹名

export class ImageLoader {
  private static instance: ImageLoader;
  private memoryCache: util.LRUCache<string, image.PixelMap>;
  private diskCachePath: string = '';

  private constructor() {
    // 初始化内存缓存
    this.memoryCache = new util.LRUCache(MEMORY_CACHE_SIZE);
  }

  // 单例模式
  public static getInstance(): ImageLoader {
    if (!ImageLoader.instance) {
      ImageLoader.instance = new ImageLoader();
    }
    return ImageLoader.instance;
  }

  /**
   * 初始化磁盘缓存路径 (建议在 Ability onCreate 中调用)
   */
  public initDiskCache(context: common.UIAbilityContext) {
    // 获取应用缓存目录
    this.diskCachePath = context.cacheDir + '/' + DISK_CACHE_DIR;
    // 创建缓存目录
    if (!fs.accessSync(this.diskCachePath)) {
      fs.mkdirSync(this.diskCachePath);
    }
  }

  /**
   * 核心加载方法
   */
  public async loadImage(url: string): Promise<image.PixelMap | null> {
    if (!url) return null;

    // 1. 检查内存缓存
    if (this.memoryCache.contains(url)) {
      console.info(`[ImageLoader] Hit Memory Cache: ${url}`);
      let imageMap = this.memoryCache.get(url) ?? null
      return imageMap;
    }

    // 2. 检查磁盘缓存
    const diskFilePath = this.getPathFromUrl(url);
    if (fs.accessSync(diskFilePath)) {
      console.info(`[ImageLoader] Hit Disk Cache: ${url}`);
      const pixelMap = await this.loadPixelMapFromDisk(diskFilePath);
      if (pixelMap) {
        this.memoryCache.put(url, pixelMap);
        return pixelMap;
      }
    }

    // 3. 网络下载
    console.info(`[ImageLoader] Downloading: ${url}`);
    return this.downloadAndSave(url);
  }

  /**
   * 从网络下载并保存
   */
  private async downloadAndSave(url: string): Promise<image.PixelMap | null> {
    try {
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: { 'Accept-Type': 'image/*' }
      });

      const imageData = response.result as ArrayBuffer;
      httpRequest.destroy();

      // 保存到磁盘
      const filePath = this.getPathFromUrl(url);
      const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      fs.writeSync(file.fd, imageData);
      fs.closeSync(file);

      // 解码为 PixelMap 并存入内存
      const imageSource = image.createImageSource(imageData);
      const pixelMap = await imageSource.createPixelMap();

      this.memoryCache.put(url, pixelMap);
      return pixelMap;

    } catch (err) {
      console.error(`[ImageLoader] Download failed: ${JSON.stringify(err)}`);
      return null;
    }
  }

  /**
   * 从磁盘文件读取并解码
   */
  private async loadPixelMapFromDisk(path: string): Promise<image.PixelMap | null> {
    try {
      const file = fs.openSync(path, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(path);
      const buffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);
      fs.closeSync(file);

      const imageSource = image.createImageSource(buffer);
      return await imageSource.createPixelMap();
    } catch (e) {
      return null;
    }
  }

  /**
   * 生成磁盘文件路径
   */
  private getPathFromUrl(url: string): string {
    // 使用 URL 的哈希值作为文件名，避免特殊字符问题
    const hashCode = HashCodeUtil.javaHashCode(url)
    return `${this.diskCachePath}/${hashCode}.jpg`;
  }


}

