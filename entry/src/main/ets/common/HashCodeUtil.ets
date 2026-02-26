/// hash code util

// 实现 Java String 的 hashCode 算法
export class HashCodeUtil {
  // Java 风格的 hashCode 算法 (s[0]*31^(n-1) + s[1]*31^(n-2) + ... + s[n-1])
  static javaHashCode(str: string): number {
    if (!str) return 0;

    let hash: number = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char; // hash * 31 + char
      hash = hash & hash; // 转换为32位整数
    }

    return hash;
  }

  // 优化版本（更接近 Java 实现）
  static javaHashCode2(str: string): number {
    let hash: number = 0;
    for (let i = 0; i < str.length; i++) {
      hash = 31 * hash + str.charCodeAt(i);
      // 转换为32位整数
      hash = hash & 0xFFFFFFFF;
    }
    return hash;
  }

  // 将负数转换为正数
  static toPositiveHashCode(hash: number): number {
    // 确保是32位有符号整数
    hash = hash | 0;
    // 如果为负数，取反
    return hash < 0 ? ~hash + 1 : hash;
  }
}
