json.extract! product, :name, :description, :price, :created_at, :updated_at, :product_id, :plan_type, :partner_name, :calories, :protein, :carbs, :fats, :user_id
json.url product_url(product, format: :json)

