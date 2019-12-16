class Product < ApplicationRecord
    #May need to change this depending on when we add the ID
    validates :stripe_id, presence: true
    has_one_attached :thumbnail
    belongs_to :user
    #Again what you're doing here is linking each product to a user 
    #via the subscription libraries. Can think of it as a massive join. 
    has_many :product_subscription_libraries
    has_many :added_products, through: :product_subscription_libraries, source: :user
end
