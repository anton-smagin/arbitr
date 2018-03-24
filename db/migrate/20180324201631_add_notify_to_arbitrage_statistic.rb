class AddNotifyToArbitrageStatistic < ActiveRecord::Migration[5.1]
  def change
    add_column :arbitrage_statistics, :notified, :bool, default: false
  end
end
