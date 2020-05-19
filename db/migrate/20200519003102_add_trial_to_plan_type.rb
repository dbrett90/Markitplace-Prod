class AddTrialToPlanType < ActiveRecord::Migration[5.2]
  def change
    add_column :plan_types, :is_trial, :string
  end
end
