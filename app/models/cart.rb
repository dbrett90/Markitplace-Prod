class Cart < ApplicationRecord
    belongs_to :user
    serialize :products, Array

end