class AddProductIdToPlanTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :plan_id, :integer
    add_column :plan_types, :product_id, :integer
  end
end
