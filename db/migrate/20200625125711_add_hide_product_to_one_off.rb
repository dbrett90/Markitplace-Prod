class AddHideProductToOneOff < ActiveRecord::Migration[5.2]
  def change
    add_column :one_off_products, :hide?, :string
  end
end
