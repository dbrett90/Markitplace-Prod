class AddIncludedCitiesToOneOffProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :one_off_products, :included_cities, :text
  end
end
