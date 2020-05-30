class Cart < ApplicationRecord
    belongs_to :user
    has_many :one_off_products
    serialize :products, Array

end