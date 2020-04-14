class AddUserIdToOneOffProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :one_off_products, :user_id, :integer
  end
end
