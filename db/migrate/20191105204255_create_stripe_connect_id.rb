class CreateStripeConnectId < ActiveRecord::Migration[5.2]
  def change
    create_table :stripe_connect_ids do |t|
      t.string :stripe_id 
      t.string :stripe_email

      t.timestamps
    end
  end
end
