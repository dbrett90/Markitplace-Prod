class ChangeColNameInProducts < ActiveRecord::Migration[5.2]
  def change
    rename_column :products, :kittype, :kit_type
    rename_column :products, :partnername, :partner_name
  end
end
