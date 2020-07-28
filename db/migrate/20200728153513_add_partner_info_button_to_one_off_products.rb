class AddPartnerInfoButtonToOneOffProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :one_off_products, :partner_background_link, :string
  end
end
