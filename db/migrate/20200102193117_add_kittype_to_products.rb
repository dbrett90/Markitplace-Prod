class AddKittypeToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :kittype, :string
  end
end
