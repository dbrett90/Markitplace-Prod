class AddIsTrialToOneOffProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :one_off_products, :is_trial, :string
  end
end
