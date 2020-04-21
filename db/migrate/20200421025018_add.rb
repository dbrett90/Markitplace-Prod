class Add < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :one_off_id, :text
  end
end
