json.extract! plan_type, :name, :description, :created_at, :updated_at, :plan_id, :stripe_id :user_id, :price, :is_true
json.url plan_type_url(plan_type, format: :json)