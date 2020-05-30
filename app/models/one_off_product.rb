class OneOffProduct < ApplicationRecord
    #May need to change this depending on when we add the ID
    #Uncomment this when we have stripe mechanism down
    # validates :stripe_id, presence: true
    has_one_attached :thumbnail
    #belongs_to :user, through: :cart
    has_many :carts
    has_many :users, through: cart
    #Again what you're doing here is linking each product to a user 
    #via the subscription libraries. Can think of it as a massive join. 
    #may need to rethink the relationship between product and subscription libraries
    #Need to think about thow this linkage is going to work... want the libraries to include subscriptions?
    #Might want to have something that shows past orders?
    # has_many :product_subscription_libraries
    # has_many :added_products, through: :product_subscription_libraries, source: :user
end