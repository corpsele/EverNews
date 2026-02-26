// 数据库
import relationalStore from '@ohos.data.relationalStore'
import { EpicFreeModel } from '../models/EpicFreeModel'
import { Constants } from './Constants'
import rdb from '@ohos.data.rdb'

export class DatabaseManager {
  private rdbStore: relationalStore.RdbStore | null = null
  private static instance: DatabaseManager

  static getInstance(): DatabaseManager {
    if (!DatabaseManager.instance) {
      DatabaseManager.instance = new DatabaseManager()
    }
    return DatabaseManager.instance
  }

  /// 初始化数据库
  async init(context: Context): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: Constants.APP_DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    }
    try {
      this.rdbStore = await relationalStore.getRdbStore(context, config)
      await this.createTables()
      console.info('Database initialized successfully');
    } catch (err) {
      console.error('Database Init Failed', JSON.stringify(err))
    }
  }

  /// 建表
  private async createTables(): Promise<void> {
    // id INTEGER PRIMARY KEY AUTOINCREMENT,
    const sql = `CREATE TABLE IF NOT EXISTS ${Constants.TABLE_EPIC} (
    id TEXT,
    title TEXT,
    cover TEXT,
    original_price INTEGER,
    original_price_desc TEXT,
    description TEXT,
    seller TEXT,
    is_free_now BIT,
    free_start TEXT,
    free_start_at INTEGER,
    free_end TEXT,
    free_end_at INTEGER,
    link TEXT
    )`
    if (this.rdbStore) {
      await this.rdbStore.executeSql(sql)
    }
  }

  async saveEpicFree(epicFrees: EpicFreeModel[]): Promise<void> {
    if (!this.rdbStore) {
      return
    }

    try {
      await this.rdbStore.beginTransaction()
      // 删除旧缓存
      // await this.rdbStore.executeSql(`DELETE FROM ${Constants.TABLE_EPIC}}`)
      for (const item of epicFrees) {
        const valueBucket: relationalStore.ValuesBucket = {
          id: item.id,
          title: item.title,
          cover: item.cover,
          original_price: item.original_price,
          original_price_desc: item.original_price_desc,
          description: item.description,
          seller: item.seller,
          is_free_now: item.is_free_now,
          free_start: item.free_start,
          free_start_at: item.free_start_at,
          free_end: item.free_end,
          free_end_at: item.free_end_at,
          link: item.link
        }
        await this.rdbStore.insert(Constants.TABLE_EPIC, valueBucket)
      }
      this.rdbStore.commit()
    } catch (err) {
      this.rdbStore.rollBack()
      console.error('[DB] save failed ', JSON.stringify(err))
    }
  }

  async insertEpicFree(
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
  ): Promise<number> {
    if (!this.rdbStore) {
      return -1
    }

    const valueBucket: relationalStore.ValuesBucket = {
      id,
      title,
      cover,
      original_price,
      original_price_desc,
      description,
      seller,
      is_free_now,
      free_start,
      free_start_at,
      free_end,
      free_end_at,
      link
    }
    return await this.rdbStore.insert(Constants.TABLE_EPIC, valueBucket)
  }

  /// 查询数据
  async queryAllEpicFree(): Promise<relationalStore.ResultSet | null> {
    if (!this.rdbStore) {
      return null
    }
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_EPIC)
    // 通过SQL语句查询
    // return await this.rdbStore.querySql('SELECT * FROM ' + Constants.TABLE_EPIC)
    return await this.rdbStore.query(predicates)
  }

  /// 查询本地数据
  async getLocalEpicFree(): Promise<EpicFreeModel[]> {
    if (!this.rdbStore) {
      return []
    }

    const resultSet = await this.rdbStore.querySql(`SELECT * FROM ${Constants.TABLE_EPIC}`)
    const epicFrees: EpicFreeModel[] = []
    while (resultSet.goToNextRow()) {
      epicFrees.push({
        id: resultSet.getString(resultSet.getColumnIndex('id')),
        title: resultSet.getString(resultSet.getColumnIndex('title')),
        cover: resultSet.getString(resultSet.getColumnIndex('cover')),
        original_price: resultSet.getLong(resultSet.getColumnIndex('original_price')),
        original_price_desc: resultSet.getString(resultSet.getColumnIndex('original_price_desc')),
        description: resultSet.getString(resultSet.getColumnIndex('description')),
        seller: resultSet.getString(resultSet.getColumnIndex('seller')),
        is_free_now: resultSet.getLong(resultSet.getColumnIndex('is_free_now')) !== 0,
        free_start: resultSet.getString(resultSet.getColumnIndex('free_start')),
        free_start_at: resultSet.getLong(resultSet.getColumnIndex('free_start_at')),
        free_end: resultSet.getString(resultSet.getColumnIndex('free_end')),
        free_end_at: resultSet.getLong(resultSet.getColumnIndex('free_end_at')),
        link: resultSet.getString(resultSet.getColumnIndex('link')),
      })
    }
    resultSet.close()
    return epicFrees
  }

}