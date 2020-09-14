class AddOptionsToOneOff < ActiveRecord::Migration[5.2]
  def change
    add_column :one_off_products, :flavor_options, :string
  end
end
