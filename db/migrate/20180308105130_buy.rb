class Buy < ActiveRecord::Migration[5.1]
  def change
    create_table :buys do |t|
      t.string :price
      t.string :symbol
      t.belongs_to :arbitrage

      t.timestamps
    end
  end
end
