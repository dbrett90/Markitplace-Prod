class AddHideToPartnerLogo < ActiveRecord::Migration[5.2]
  def change
    add_column :partner_logos, :hide?, :string
  end
end
