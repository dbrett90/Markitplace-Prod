class ChangePartnerInformationToPartnerBackgrounds < ActiveRecord::Migration[5.2]
  def change
    rename_table :partner_informations, :partner_backgounds
  end
end
