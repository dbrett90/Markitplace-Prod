class AddCaloriesToPlanTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :plan_types, :calories, :integer
    add_column :plan_types, :protein, :integer
    add_column :plan_types, :servings, :integer
    add_column :plan_types, :fats, :integer
    add_column :plan_types, :prep_time, :integer
  end
end
