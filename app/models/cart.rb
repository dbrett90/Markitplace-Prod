class Cart < ApplicationRecord
    belongs_to :user, optional: true
    belongs_to :guest_user, optional: true
    has_many :one_off_products
    has_many :plan_types
    serialize :products, Array
    # #Proper Checkout - institute checkout?
    has_many :line_items

end