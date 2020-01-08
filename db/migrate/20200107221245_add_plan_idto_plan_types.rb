class AddPlanIdtoPlanTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :plan_types, :product_id, :integer
  end
end
