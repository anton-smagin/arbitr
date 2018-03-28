class CreateSpreadTrade < ActiveRecord::Migration[5.1]
  def change
    create_table :spread_trades do |t|
      t.string :status
      t.float :buy_price
      t.float :sell_price
    end
  end
end
