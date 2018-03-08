class Arbitrage < ActiveRecord::Migration[5.1]
  def change
    create_table :arbitrages do |t|
      t.string :from_price
      t.string :to_price
      t.string :from_market
      t.string :to_market
      t.string :symbol
      t.string :status

      t.timestamps
    end
  end
end
