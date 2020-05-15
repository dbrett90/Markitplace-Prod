class PartnerLogoTable < ActiveRecord::Migration[5.2]
  def change
    create_table :partner_logos do |t|
      t.string :name
      t.text :description
    end
  end
end
