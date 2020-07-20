class AddDeliveryScheduleToOneOffProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :one_off_products, :delivery_schedule, :text
  end
end
