class Sell < ActiveRecord::Migration[5.1]
  def change
    create_table :sells do |t|
      t.string :price
      t.string :symbol
      t.belongs_to :arbitrage

      t.timestamps
    end
  end
end
