class CreateTransfer < ActiveRecord::Migration[5.1]
  def change
    create_table :transfers do |t|
      t.string :type
      t.float :amount
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
