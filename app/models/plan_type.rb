#YOURE REFACTORING THE CODE TO SHOW PLANS FIRST AND LINK THEM TO PRODUCTS
#NEED TO UPDATE THE MODELS, DATABASES, 
class PlanType < ApplicationRecord
    has_many :products
    has_one_attached :thumbnail
    has_many :carts
    has_many :users, through: :carts

    #This is for linking and then showing those plans
    #Again what you're doing here is linking each product to a user 
    #via the subscription libraries. Can think of it as a massive join. 
    has_many :plan_subscription_libraries
    has_many :added_plans, through: :plan_subscription_libraries, source: :user
end
