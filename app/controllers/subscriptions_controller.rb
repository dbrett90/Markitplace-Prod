class SubscriptionsController < ApplicationController
    
    def new
        @plans = PlanType.all
        if logged_in? && current_user.subscribed?
            redirect_to root_path, notice: "You are already subscribed!"
        end
    end

    #Need to add a mailer after an account has been created... ADD THIS IN
    def create
        #Make sure we change this to production when the time comes
        Stripe.api_key = Rails.application.credentials.development[:stripe_api_key]

        #Make sure that the credentials file has the appropriate plan_ids
        plan_id = params[:plan_id]
        plan = Stripe::Plan.retrieve(plan_id)
        token = params[:stripeToken]
        # flash[:warning] = Stripe.api_key

        customer = if current_user.stripe_id.present?
            Stripe::Customer.retrieve(current_user.stripe_id)
            # flash[:danger] = "User already has a stripe ID!"
        else
            Stripe::Customer.create({
                email: current_user.email, 
                source:token,
            })
            # Stripe::Customer.create(description: 'Test Customer')
            #Save the stripe id to the database
        end
        subscription = customer.subscriptions.create(plan: plan.id)
        options = {
            stripe_id: customer.id,
            stripe_subscription_id: subscription.id,
            subscribed: true
        }
        flash[:danger] = subscription.class
        flash[:success] = subscription

        # #Doing a merge if card value is updated. Below function will check this
        options.merge!(
            card_last4: params[:user][:card_last4],
            card_exp_month: params[:user][:card_exp_month],
            card_exp_year: params[:user][:card_exp_year],
            card_type: params[:user][:card_type]
            ) if params[:user][:card_last4]
            current_user.update(options)
            redirect_to root_path

            #Trigger Flash & The action mailers for confirmation
            #flash[:success] = "Your subscription is now active! Please check your email for a confirmation notice."
            # OrderConfirmationMailer.customer_confirmation(params[:payment_shipping][:plan], 
            # params[:payment_shipping][:recipient_name], params[:payment_shipping][:street_address_1],
            # params[:payment_shipping][:street_address_2], params[:payment_shipping][:city],
            # params[:payment_shipping][:state], params[:payment_shipping][:zipcode])
    end

    def destroy
        customer = Stripe::Customer.retrieve(current_user.stripe_id)
        customer.subscriptions.retrieve(current_user.stripe_subscription_id).delete
        current_user.update(stripe_subscription_id: nil)
        current_user.subscribed = false

        redirect_to root_path, notice: "Your subscription has been cancelled"
    end
end
