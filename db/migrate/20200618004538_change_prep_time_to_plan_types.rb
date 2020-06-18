class ChangePrepTimeToPlanTypes < ActiveRecord::Migration[5.2]
  def change
    change_column :plan_types, :prep_time, :string
  end
end
