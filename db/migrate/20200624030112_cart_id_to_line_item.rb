class CartIdToLineItem < ActiveRecord::Migration[5.2]
  def change
    add_column :line_items, :cart_id, :integer
  end
end
