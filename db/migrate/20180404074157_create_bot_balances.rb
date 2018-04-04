class CreateBotBalances < ActiveRecord::Migration[5.1]
  def change
    create_table :bot_balances do |t|
      t.float :livecoin
      t.float :binance

      t.timestamps
    end
  end
end
