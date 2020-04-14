class AddStripeIdToOneOffProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :one_off_products, :stripe_id, :string
  end
end
