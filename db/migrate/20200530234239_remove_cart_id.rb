class RemoveCartId < ActiveRecord::Migration[5.2]
  def change
    remove_column :one_off_products, :cart_id
  end
end
