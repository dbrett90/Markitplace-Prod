class AddPrepTimeToOneOffProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :one_off_products, :prep_time, :string
  end
end
