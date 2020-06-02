class AddCartIdToPlanType < ActiveRecord::Migration[5.2]
  def change
    add_column :plan_types, :cart_id, :integer
  end
end
