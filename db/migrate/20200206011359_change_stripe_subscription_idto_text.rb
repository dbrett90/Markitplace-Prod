class ChangeStripeSubscriptionIdtoText < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :stripe_subscription_id, :text
  end
end
