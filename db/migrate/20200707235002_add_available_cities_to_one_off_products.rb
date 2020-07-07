class AddAvailableCitiesToOneOffProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :one_off_products, :available_cities, :text
  end
end
