class CreateTableGuestUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :guest_users, :user_name, :string
    add_column :guest_users, :email, :string
    add_column :guest_users, :phone_number, :string
  end
end
