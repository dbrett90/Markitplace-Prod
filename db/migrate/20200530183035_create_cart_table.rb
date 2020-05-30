class CreateCartTable < ActiveRecord::Migration[5.2]
  def change
    create_table :carts do |t|
      t.integer :user_id
      t.text :products

      t.timestamps
    end
  end
end
