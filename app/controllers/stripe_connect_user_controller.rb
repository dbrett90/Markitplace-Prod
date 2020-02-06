class StripeConnectUserController < ApplicationController

    def new
        Stripe.api_key = Rails.application.credentials.development[:stripe_api_key]
        auth_code = params[:code]
        response = Stripe::OAuth.token({
          grant_type: 'authorization_code',
          code: auth_code
        })
        dummy_email = "dbrett14@gmail.com"
        connected_account_id = response.stripe_user_id
        #flash[:warning] = response
        linkedAccount = Stripe::Account.retrieve(connected_account_id)
        #linkedEmail = email_exists?(linkedAccount)
        @stripe_connect_user = StripeConnectUser.new
        @stripe_connect_user.stripe_id = connected_account_id
        @stripe_connect_user.stripe_email = linkedAccount.email
        @stripe_connect_user.save
        @stripe_connect_user.send_instructions_email
        flash[:success] = "Your stripe account has now been linked! An email with instructions has been sent"
        render 'static_pages/home' 
    end

    #Need to updae the user params field here
    #Reflect that we want a stripe ID and Stripe Email
    private

    def user_params
      params.require(:stripe_connect_user).permit(:stripe_email, :stripe_connect_id)
    end

    #Will need to update this when pushing to production
    def email_exists?(accountObject)
      if accountObject.email.nil? | accountObject.object.empty?
        returnObject = "dbrett14@gmail.com"
      else
        accountObject = testCustomer.email
      end
    end

end
