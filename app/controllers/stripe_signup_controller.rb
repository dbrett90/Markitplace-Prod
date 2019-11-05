class StripeSignupController < ApplicationController

    def new
        Stripe.api_key = Rails.application.credentials.development[:stripe_api_key]
        @user = User.new()
        auth_code = params[:code]
        response = Stripe::OAuth.token({
          grant_type: 'authorization_code',
          code: auth_code
        })
        connected_account_id = response.stripe_user_id
        #Check that you have the connected account ID
        flash[:success] = connected_account_id
        flash[:danger] = auth_code
        render 'static_pages/home' 
    end
end
