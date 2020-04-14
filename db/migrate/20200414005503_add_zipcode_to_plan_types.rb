class AddZipcodeToPlanTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :plan_types, :zipcodes, :text
  end
end
