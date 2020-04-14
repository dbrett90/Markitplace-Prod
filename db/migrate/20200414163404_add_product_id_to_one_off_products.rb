class AddProductIdToOneOffProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :one_off_products, :product_id, :string
  end
end
