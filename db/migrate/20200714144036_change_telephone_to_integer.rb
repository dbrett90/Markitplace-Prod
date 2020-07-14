class ChangeTelephoneToInteger < ActiveRecord::Migration[5.2]
  def change
    change_column :playbook_users, :phone_number, :text
  end
end
