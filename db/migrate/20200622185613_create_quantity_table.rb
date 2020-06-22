class CreateQuantityTable < ActiveRecord::Migration[5.2]
  def change
    create_table :quantities do |t|
      t.integer :quantity
    end
  end
end
