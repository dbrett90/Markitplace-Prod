class AddPriceToPlanTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :plan_types, :price, :decimal
  end
end
