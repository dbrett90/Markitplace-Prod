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
        one_off_purchases = OneOffProduct.all
        #Call private function to match with the correct one off puchase
        one_off_purchase = find_one_off(one_off_product_name, one_off_purchases)
        #pull the connected ID from the database
        connected_acct = one_off_purchase.stripe_id
        flash[:success] = connected_acct
        # flash[:success] = one_off_purchase
        # redirect_to root_path

        #NOTE: NEED TO DETERMINE IF ONE OFFS WILL BE LIMITED GEOGRAPHICALLY - BUILD INTO DATABASE ROWS
        customer = if current_user.stripe_id[connected_acct].present?
            Stripe::Customer.retrieve(current_user.stripe_id[connected_acct], {stripe_account: one_off_purchase.stripe_id})
        else
            #Create customer in connected accounts environment.
            Stripe::Customer.create({
                email: current_user.email, 
                source:token,
            },
            {
                stripe_account: one_off_purchase.stripe_id,
            })
            # Stripe::Customer.create(description: 'Test Customer')
            #Save the stripe id to the database
        end
        #Save the stripe ID to the database of the newly created customer in the connected account
        current_user.stripe_id[connected_acct] = customer.id
        #SUBSCCRIBED = TRUE?
        #Need to clarify why we need options here for the card_last4 etc... Necessary?
        #Check the code on subscribed feature
        options = {
            subscribed: true
        }

        options.merge!(
            card_last4: params[:user][:card_last4],
            card_exp_month: params[:user][:card_exp_month],
            card_exp_year: params[:user][:card_exp_year],
            card_type: params[:user][:card_type]
            ) if params[:user][:card_last4]
        #May need to change one_off_id for naming convention
        # current_user.one_off_id[one_off_purchase.name.downcase] = payment_intent.id
        current_user.update(options)
        #For the hash portion
        current_user.save
        
        # payment_intent = Stripe::PaymentIntent.create({
        #     payment_method_types: ['card'],
        #     amount: (one_off_purchase.price * 1000).to_i,
        #     currency: 'usd',
        #     customer: customer,
        #     transfer_data: {
        #         destination: one_off_purchase.stripe_id,
        #     },
        # })

        redirect_to root_path
        
        

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