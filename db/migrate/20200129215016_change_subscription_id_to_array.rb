class ChangeSubscriptionIdToArray < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :stripe_subscription_id, :string, array: true, using: "(string_to_array(stripe_subscription_id, ','))"
  end
end
