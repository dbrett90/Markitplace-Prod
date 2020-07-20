class AddHqToPartnerLogos < ActiveRecord::Migration[5.2]
  def change
    add_column :partner_logos, :headquarters, :string
  end
end
