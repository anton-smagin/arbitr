class CreateSpreadTrade < ActiveRecord::Migration[5.1]
  def change
    create_table :spread_trades do |t|
      t.string :exchange
      t.string :symbol
      t.string :status
      t.bigint :buy_order_id
      t.float :buy_price
      t.float :buy_amount
      t.bigint :sell_order_id
      t.float :sell_price
      t.float :sell_amount
    end
  end
end
