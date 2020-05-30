class AddCartIdToOneOffProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :carts, :one_off_product_id, :integer 
  end
end
