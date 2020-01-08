class RemoveColumnsToProducts < ActiveRecord::Migration[5.2]
  def change
    rename_column :products, :kit_type, :plan_type
    remove_column :products, :user_id
    remove_column :products, :stripe_id
    remove_column :products, :price
  end
end
