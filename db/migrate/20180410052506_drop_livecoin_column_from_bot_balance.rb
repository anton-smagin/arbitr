class DropLivecoinColumnFromBotBalance < ActiveRecord::Migration[5.1]
  def change
    remove_column :bot_balances, :livecoin, :float
  end
end
