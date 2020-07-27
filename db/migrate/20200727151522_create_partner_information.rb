class CreatePartnerInformation < ActiveRecord::Migration[5.2]
  def change
    create_table :partner_informations do |t|
      t.string :name
      t.text :tag_line
      t.text :description
    end
  end
end
