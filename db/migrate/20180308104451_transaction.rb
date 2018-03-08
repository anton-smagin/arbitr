class Transaction < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.string :from
      t.string :to
      t.string :address
      t.string :coin
      t.belongs_to :arbitrage

      t.timestamps
    end
  end
end
