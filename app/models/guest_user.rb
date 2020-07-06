class GuestUser < ApplicationRecord
    #Specific to Cart - saying each guest user has a cart
    has_one :cart, dependent: :destroy
    has_many :one_off_products, through: :cart
    has_many :line_items, through: :cart

    #Updated to refelect plan association.. Each user associated with a PLAN
    has_many :plan_types, through: :cart
end