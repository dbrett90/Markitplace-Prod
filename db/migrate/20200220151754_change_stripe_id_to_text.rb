class ChangeStripeIdToText < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :stripe_id, :text
  end
end
