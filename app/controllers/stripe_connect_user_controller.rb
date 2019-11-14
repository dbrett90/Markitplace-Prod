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
        @stripe_connect_user = StripeConnectUser.new(connected_account_id, dummy_email)
        @stripe_connect_user.save
        #Check that you have the connected account ID
        flash[:success] = connected_account_id
        flash[:danger] = auth_code
        flash[:notice] = "User has been saved successfully"
        render 'static_pages/home' 
    end
end
