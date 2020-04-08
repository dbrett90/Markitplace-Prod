class MakeDateTimesNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column :one_off_products, :created_at, :datetime, null: false
    change_column :one_off_products, :updated_at, :datetime, null: false
  end
end
