class AddParternameToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :partnername, :string
  end
end
