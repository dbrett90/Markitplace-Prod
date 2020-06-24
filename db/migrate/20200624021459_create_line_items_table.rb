class CreateLineItemsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :line_items do |t|
      t.integer :product_id
      t.integer :quantity
      t.string :product_type
    end
  end
end
