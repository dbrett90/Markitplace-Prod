class ProductSubscriptionLibrary < ApplicationRecord
    #Think of this class as the intermediary between the user and a given product
    #Essentially can think of it as a holding device for each of the products a user has.
    belongs_to :subscription
    belongs_to :user
end
