class CreateTablePlaybookUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :playbook_users do |t|
      t.string :name
      t.string :email
      t.integer :phone_number
    end
  end
end
