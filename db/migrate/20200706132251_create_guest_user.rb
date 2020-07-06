class CreateGuestUser < ActiveRecord::Migration[5.2]
  def change
    create_table :guest_users do |t|
      t.integer :cart_id
    end
  end
end
