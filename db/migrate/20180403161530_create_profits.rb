class CreateProfits < ActiveRecord::Migration[5.1]
  def change
    create_table :profits do |t|
      t.float :amount
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
