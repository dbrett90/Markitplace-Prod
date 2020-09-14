class AddFlavorOptionsToLineItems < ActiveRecord::Migration[5.2]
  def change
    add_column :line_items, :flavor_option, :string
  end
end
