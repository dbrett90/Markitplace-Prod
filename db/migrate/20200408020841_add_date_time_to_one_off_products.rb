class AddDateTimeToOneOffProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :one_off_products, :created_at, :datetime 
    add_column :one_off_products, :updated_at, :datetime
  end
end
