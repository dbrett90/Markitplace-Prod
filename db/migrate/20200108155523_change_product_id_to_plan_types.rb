class ChangeProductIdToPlanTypes < ActiveRecord::Migration[5.2]
  def change
    rename_column :plan_types, :product_id, :plan_id
  end
end
