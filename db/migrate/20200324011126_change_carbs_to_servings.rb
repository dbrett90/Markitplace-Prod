class ChangeCarbsToServings < ActiveRecord::Migration[5.2]
  def change
    rename_column :products, :carbs, :servings
  end
end
