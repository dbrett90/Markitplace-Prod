class AddAddOnToOneOffProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :one_off_products, :add_on, :string
  end
end
