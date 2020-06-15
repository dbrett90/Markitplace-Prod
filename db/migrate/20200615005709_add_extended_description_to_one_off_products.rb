class AddExtendedDescriptionToOneOffProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :one_off_products, :extended_description, :text
  end
end
