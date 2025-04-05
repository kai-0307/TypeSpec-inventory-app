import "@typespec/http";
import "@typespec/rest";

using TypeSpec.Http;
using TypeSpec.Rest;

/**
 * Stock Service API
 */
@service
@server("http://localhost:8080", "Stock Service API")
@route("/api/service-1")
namespace StockService {
  //----------------------
  // モデル定義
  //----------------------

  /**
   * 在庫モデル
   */
  model Stock {
    /** 商品ID */
    id: string;

    /** 商品名（必須） */
    @minLength(1)
    name: string;

    /** 商品の説明 */
    description: string;

    /** 在庫数量（0以上の値） */
    @minValue(0)
    quantity: int32;

    /** 在庫の単位（個、kg、箱など） */
    unit: string;

    /** 最小在庫数量アラートの閾値 */
    @minValue(0)
    min_quantity: int32;

    /** レコード作成日時 */
    created_at?: string;

    /** 最終更新日時 */
    updated_at?: string;
  }

  /**
   * 在庫数量更新リクエスト
   */
  model QuantityUpdate {
    /** 在庫数量の調整値（正の値は追加、負の値は減少） */
    adjustment: int32;

    /** 調整の理由（オプション） */
    note?: string;
  }

  /**
   * 標準レスポンス
   */
  model StandardResponse<T> {
    /** 操作が成功したかどうか */
    success: boolean;

    /** レスポンスメッセージ */
    message?: string;

    /** レスポンスデータ */
    data?: T;
  }

  /**
   * エラーレスポンス
   */
  model ErrorResponse {
    /** 常にfalse */
    success: boolean = false;

    /** エラーメッセージ */
    error: string;

    /** エラーコード */
    code: int32;
  }

  /**
   * 在庫コレクション
   */
  model StockCollection {
    /** 在庫アイテムのリスト */
    items: Stock[];

    /** 総アイテム数 */
    total: int32;
  }

  /**
   * 低在庫チェック結果
   */
  model LowStockResponse {
    /** 在庫が最小閾値以下かどうか */
    is_low_stock: boolean;

    /** 現在の在庫数 */
    current_quantity: int32;

    /** 最小閾値 */
    min_quantity: int32;
  }

  //----------------------
  // API定義
  //----------------------

  /**
   * 在庫管理APIインターフェース
   */
  @route("stocks")
  @tag("Stocks")
  interface StocksAPI {
    /**
     * 全ての在庫を取得
     * @returns 在庫のリスト
     */
    @get
    @summary("Get all stocks")
    listStocks(): StandardResponse<StockCollection> | ErrorResponse;

    /**
     * 特定の在庫をIDで取得
     * @param id 取得する在庫のID
     * @returns 指定されたID の在庫情報
     */
    @route("{id}")
    @get
    @summary("Get a specific stock by ID")
    getStock(@path id: string): StandardResponse<Stock> | ErrorResponse;

    /**
     * 新しい在庫を作成
     * @param request 作成する在庫情報
     * @returns 作成された在庫情報
     */
    @post
    @summary("Create a new stock")
    createStock(@body request: Stock): StandardResponse<Stock> | ErrorResponse;

    /**
     * 在庫情報を更新
     * @param id 更新する在庫のID
     * @param request 更新内容
     * @returns 更新された在庫情報
     */
    @route("{id}")
    @put
    @summary("Update a stock")
    updateStock(
      @path id: string,
      @body request: OmitProperties<Stock, "id" | "created_at" | "updated_at">
    ): StandardResponse<Stock> | ErrorResponse;

    /**
     * 在庫を削除
     * @param id 削除する在庫のID
     * @returns 削除結果
     */
    @route("{id}")
    @delete
    @summary("Delete a stock")
    deleteStock(@path id: string): StandardResponse<{}> | ErrorResponse;

    /**
     * 在庫数量を調整
     * @param id 調整する在庫のID
     * @param update 数量調整情報
     * @returns 調整後の在庫情報
     */
    @route("{id}/quantity")
    @patch
    @summary("Update stock quantity")
    updateStockQuantity(
      @path id: string,
      @body update: QuantityUpdate
    ): StandardResponse<Stock> | ErrorResponse;

    /**
     * 在庫が最小閾値以下かどうかを確認
     * @param id 確認する在庫のID
     * @returns 低在庫状態かどうかの情報
     */
    @route("{id}/low-stock")
    @get
    @summary("Check if stock is below minimum threshold")
    isLowStock(@path id: string): StandardResponse<LowStockResponse> | ErrorResponse;
  }
}
