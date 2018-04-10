class RenameAmountColumnInSpreadTrade < ActiveRecord::Migration[5.1]
  def change
    rename_column :spread_trades, :buy_amount, :amount
    remove_column :spread_trades, :sell_amount
  end
end
