class AddRecipeIntstructionsUrlToOneOffProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :one_off_products, :recipe_instructions_link, :string
  end
end
