class AddSortPriotityToPartnerLogos < ActiveRecord::Migration[5.2]
  def change
    add_column :partner_logos, :sort_priority, :integer
  end
end
