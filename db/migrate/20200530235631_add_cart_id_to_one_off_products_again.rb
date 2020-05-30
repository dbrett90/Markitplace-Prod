class AddCartIdToOneOffProductsAgain < ActiveRecord::Migration[5.2]
  def change
    add_column :one_off_products, :cart_id, :integer
  end
end
