class CreateTestData < ActiveRecord::Migration[5.1]
  def change
    create_table :test_data do |t|
      t.text :symbol
      t.float :price
      t.float :adx
      t.text :alligator
      t.datetime :time
      t.text :interval
      t.text :market

      t.timestamps
    end
  end
end
