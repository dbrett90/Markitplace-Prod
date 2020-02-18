class ChangePlanTypeIdToString < ActiveRecord::Migration[5.2]
  def change
    change_column :plan_types, :plan_type_id, :string
  end
end
