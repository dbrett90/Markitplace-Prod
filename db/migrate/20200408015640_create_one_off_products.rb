class CreateOneOffProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :one_off_products do |t|
      t.string :name
      t.text :description
      t.float :price
      t.string :partner_name
    end
  end
end
