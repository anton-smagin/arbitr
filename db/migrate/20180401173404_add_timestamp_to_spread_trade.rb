class AddTimestampToSpreadTrade < ActiveRecord::Migration[5.1]
  def change
    add_column :spread_trades, :created_at, :datetime
    add_column :spread_trades, :updated_at, :datetime
  end
end
