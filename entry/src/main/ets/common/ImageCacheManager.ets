/// 图片缓存封装

import http from '@ohos.net.http';
import fs from '@ohos.file.fs';
import image from '@ohos.multimedia.image';
import common from '@ohos.app.ability.common';

export class ImageCacheManager {
  private static instance: ImageCacheManager;
  private context?: Context;
  // 内存缓存：存储 PixelMap 对象
  private memoryCache: Map<string, image.PixelMap> = new Map();
  // 缓存目录
  private cacheDir: string = '';
  // 单例模式
  public static getInstance(): ImageCacheManager {
    if (!ImageCacheManager.instance) {
      ImageCacheManager.instance = new ImageCacheManager();
    }
    return ImageCacheManager.instance;
  }
  // 初始化，需要在 Ability 入口调用
  public init(context: common.Context): void {
    this.context = context;
    this.cacheDir = context.cacheDir; // 应用缓存目录
  }

  /**
   * 核心方法：加载图片
   * 优先级：内存缓存 -> 磁盘缓存 -> 网络下载
   */
  public async loadImage(url: string): Promise<image.PixelMap | null> {
    if (!url) return null;
    // 1. 检查内存缓存
    if (this.memoryCache.has(url)) {
      console.info(`[Cache] Hit Memory: ${url}`);
      return this.memoryCache.get(url)!;
    }
    // 2. 检查磁盘缓存
    const localPath = this.getLocalPath(url);
    if (fs.accessSync(localPath)) {
      console.info(`[Cache] Hit Disk: ${url}`);
      const pixelMap = await this.loadFromDisk(localPath);
      if (pixelMap) {
        this.memoryCache.set(url, pixelMap); // 存入内存缓存
        return pixelMap;
      }
    }
    // 3. 网络下载
    console.info(`[Cache] Downloading: ${url}`);
    return await this.downloadAndSave(url);
  }
  /**
   * 下载并保存图片
   */
  private async downloadAndSave(url: string): Promise<image.PixelMap | null> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.ARRAY_BUFFER, // 关键：接收二进制流
        connectTimeout: 60000,
        readTimeout: 60000,
      });
      if (response.responseCode === 200 && response.result) {
        const buffer = response.result as ArrayBuffer;

        // 保存到磁盘
        this.saveToDisk(url, buffer);

        // 解码为 PixelMap
        const pixelMap = await this.bufferToPixelMap(buffer);

        // 存入内存缓存
        if (pixelMap) {
          this.memoryCache.set(url, pixelMap);
        }
        return pixelMap;
      }
    } catch (err) {
      console.error(`[Cache] Download failed: ${JSON.stringify(err)}`);
    } finally {
      httpRequest.destroy();
    }
    return null;
  }
  /**
   * 工具：将 Buffer 转为 PixelMap
   */
  private async bufferToPixelMap(buffer: ArrayBuffer): Promise<image.PixelMap | null> {
    try {
      const imageSource = image.createImageSource(buffer);
      const pixelMap = await imageSource.createPixelMap();
      return pixelMap;
    } catch (e) {
      console.error('[Cache] PixelMap decode failed');
      return null;
    }
  }
  /**
   * 工具：保存到磁盘
   */
  private saveToDisk(url: string, buffer: ArrayBuffer): void {
    const localPath = this.getLocalPath(url);
    try {
      const file = fs.openSync(localPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      fs.writeSync(file.fd, buffer);
      fs.closeSync(file);
      console.info(`[Cache] Saved to Disk: ${localPath}`);
    } catch (err) {
      console.error(`[Cache] Save failed: ${JSON.stringify(err)}`);
    }
  }
  /**
   * 工具：从磁盘加载
   */
  private async loadFromDisk(path: string): Promise<image.PixelMap | null> {
    try {
      const file = fs.openSync(path, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(path);
      const buffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);
      fs.closeSync(file);
      return await this.bufferToPixelMap(buffer);
    } catch (e) {
      return null;
    }
  }
  /**
   * 工具：生成缓存文件路径
   */
  private getLocalPath(url: string): string {
    // 简单哈希处理文件名，防止特殊字符
    const fileName = url.split('/').pop() || `img_${Date.now()}`;
    return `${this.cacheDir}/${fileName}`;
  }
}