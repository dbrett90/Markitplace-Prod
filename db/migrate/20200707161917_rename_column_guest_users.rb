class RenameColumnGuestUsers < ActiveRecord::Migration[5.2]
  def change
    rename_column :guest_users, :user_name, :name
  end
end
