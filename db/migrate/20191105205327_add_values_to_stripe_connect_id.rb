class AddValuesToStripeConnectId < ActiveRecord::Migration[5.2]
  def change
    add_column :stripe_connect_ids, :firstname, :string
    add_column :stripe_connect_ids, :lastname, :string
  end
end
