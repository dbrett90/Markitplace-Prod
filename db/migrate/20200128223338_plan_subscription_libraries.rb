class PlanSubscriptionLibraries < ActiveRecord::Migration[5.2]
  def change
    create_table :plan_subscription_libraries do |t|
      t.integer :plan_type_id
      t.integer :user_id

      t.timestamps
    end
  end
end
