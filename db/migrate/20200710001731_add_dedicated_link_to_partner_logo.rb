class AddDedicatedLinkToPartnerLogo < ActiveRecord::Migration[5.2]
  def change
    add_column :partner_logos, :dedicated_link, :string
  end
end
