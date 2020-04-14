class RenameZipCodesToPlanType < ActiveRecord::Migration[5.2]
  def change
    rename_column :plan_types, :zipcodes, :city_delivery
  end
end
