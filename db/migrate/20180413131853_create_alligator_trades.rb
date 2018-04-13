class CreateAlligatorTrades < ActiveRecord::Migration[5.1]
  def change
    create_table :alligator_trades do |t|
      t.string :exchange
      t.string :symbol
      t.string :status
      t.float :amount
      t.float :buy_price
      t.float :sell_price

      t.timestamps
    end
  end
end
