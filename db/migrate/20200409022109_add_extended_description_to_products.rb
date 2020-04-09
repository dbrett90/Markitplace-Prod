class AddExtendedDescriptionToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :plan_types, :extended_description, :text
  end
end
