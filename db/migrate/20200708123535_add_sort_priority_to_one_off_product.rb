class AddSortPriorityToOneOffProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :one_off_products, :sort_priority, :integer
  end
end
