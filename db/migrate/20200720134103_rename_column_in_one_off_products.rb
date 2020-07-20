class RenameColumnInOneOffProducts < ActiveRecord::Migration[5.2]
  def change
    rename_column :one_off_products, :hide?, :hide
  end
end
