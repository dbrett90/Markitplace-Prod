class AddNutritionFactsToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :calories, :integer
    add_column :products, :protein, :integer
    add_column :products, :carbs, :integer
    add_column :products, :fats, :integer
  end
end
