class ChangeStripeConnectIdsToStripeConnectUsers < ActiveRecord::Migration[5.2]
  def change
    rename_table :stripe_connect_ids, :stripe_connect_users
  end
end
