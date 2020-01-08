class CreatePlanTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :plan_types do |t|
      t.string :name
      t.text :description
      t.string :stripe_id
      t.integer :user_id

      t.timestamps
    end
  end
end
