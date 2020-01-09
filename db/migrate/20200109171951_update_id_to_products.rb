class UpdateIdToProducts < ActiveRecord::Migration[5.2]
  def change
    rename_column :products, :plan_id, :plan_type_id
    rename_column :plan_types, :plan_id, :plan_type_id
  end
end
