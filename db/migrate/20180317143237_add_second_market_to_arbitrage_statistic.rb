class AddSecondMarketToArbitrageStatistic < ActiveRecord::Migration[5.1]
  def change
    add_column :arbitrage_statistics, :second_market, :string
  end
end
