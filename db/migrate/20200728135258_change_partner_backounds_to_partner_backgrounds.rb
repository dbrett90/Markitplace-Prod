class ChangePartnerBackoundsToPartnerBackgrounds < ActiveRecord::Migration[5.2]
  def change
    rename_table :partner_backgounds, :partner_backgrounds
  end
end
