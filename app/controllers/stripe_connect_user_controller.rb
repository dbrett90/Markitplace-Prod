class StripeConnectUserController < ApplicationController

    def new
        Stripe.api_key = Rails.application.credentials.development[:stripe_api_key]
        auth_code = params[:code]
        response = Stripe::OAuth.token({
          grant_type: 'authorization_code',
          code: auth_code
        })
        dummy_email = "danbrett107@gmail.com"
        connected_account_id = response.stripe_user_id
        testCustomer = Stripe::Account.retrieve(connected_account_id)
        returnObject = testCustomer.email
        @stripe_connect_user = StripeConnectUser.new
        @stripe_connect_user.stripe_id = connected_account_id
        @stripe_connect_user.stripe_email = dummy_email 
        @stripe_connect_user.save
        #Check that you have the connected account ID - remove flash statements when
        #Not needed
        # flash[:notice] = connected_account_id
        # flash[:danger] = auth_code
        flash[:success] = "Your stripe account has now been linked! An email with instructions has been sent"
        flash[:danger] = returnObject
        render 'static_pages/home' 
    end

    #Need to updae the user params field here
    #Reflect that we want a stripe ID and Stripe Email
    private

    def user_params
      params.require(:stripe_connect_user).permit(:stripe_email, :stripe_connect_id)
    end
end
