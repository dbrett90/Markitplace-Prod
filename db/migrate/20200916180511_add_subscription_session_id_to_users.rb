class AddSubscriptionSessionIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :subscription_session_id, :text
  end
end
