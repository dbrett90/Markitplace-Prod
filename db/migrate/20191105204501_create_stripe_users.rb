class CreateStripeUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :stripe_users do |t|

      t.timestamps
    end
  end
end
