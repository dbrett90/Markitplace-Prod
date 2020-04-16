class PurchaseOneOffsController < ApplicationController 
    def new
        #Give access to all plan types
        @one_off_products = OneOffProduct.all
        flash[:warning ] = params
    end

    def create
        #Make sure we change this to production when the time comes
        Stripe.api_key = Rails.application.credentials.development[:stripe_api_key]
        one_off_product_name = params[:one_off_product_name]
        token = params[:stripeToken]
        #Going to correctly identify the proper plan here
        one_off_purchases = OneOffPurchase.all
        #Call private function to match with the correct one off puchase
        one_off_purchase = find_one_off
        flash[:success] = one_off_purchase
    end

    #Do we want this ability to cancel orders in the code?
    def destroy
    end

    private

    def find_one_off(stripe_one_off, one_off_purchases)
        one_off_purchases.each do |one_off|
            if stripe_one_off == one_off.name.downcase
                return one_off
            end
        end
    end


end