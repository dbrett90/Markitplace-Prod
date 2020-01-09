class UpdatePlanTypeNameinProduct < ActiveRecord::Migration[5.2]
  def change
    rename_column :products, :plan_type, :plan_type_name
  end
end
