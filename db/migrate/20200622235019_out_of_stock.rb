class OutOfStock < ActiveRecord::Migration[5.2]
  def change
    add_column :one_off_products, :out_of_stock, :string
  end
end
