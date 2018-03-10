class ArbitrageStatistics < ActiveRecord::Migration[5.1]
  def change
    create_table :arbitrage_statistics do |t|
      t.float :percent
      t.string :symbol
      t.string :first_market

      t.timestamps
    end
  end
end
