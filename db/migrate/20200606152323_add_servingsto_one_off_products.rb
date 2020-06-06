class AddServingstoOneOffProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :one_off_products, :servings, :integer
  end
end
