
/// 模型
export interface EpicFreeModel {
  id: string,
  title: string,
  cover: string,
  original_price: number,
  original_price_desc: string,
  description: string,
  seller: string,
  is_free_now: boolean,
  free_start: string,
  free_start_at: number,
  free_end: string,
  free_end_at: number,
  link: string
}