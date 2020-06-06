class AddCaloriesToOneOffProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :one_off_products, :calories, :integer
    add_column :one_off_products, :fats, :integer
    add_column :one_off_products, :protein, :integer
  end
end
