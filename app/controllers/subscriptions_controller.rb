class SubscriptionsController < ApplicationController    
    def new
        @plans = PlanType.all
        if logged_in? && current_user.subscribed?
             flash[:warning] = "Please note that you are already subscribed to one plan. You can view
             your current subscriptions from the navbar"
        end
    end

    #Need to add a mailer after an account has been created... ADD THIS IN
    #But of an ugly controller - might need to change this to make it more concise
    def create
        #Make sure we change this to production when the time comes
        Stripe.api_key = Rails.application.credentials.development[:stripe_api_key]

        #Make sure that the credentials file has the appropriate plan_ids
        plan_id = params[:plan_id]
        plan = Stripe::Plan.retrieve(plan_id)
        # flash[:warning] = plan
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
        current_user.stripe_subscription_id << subscription.id
        options = {
            stripe_id: customer.id,
            #Gonna need to check this line here
            # stripe_subscription_id << subscription.id,
            subscribed: true
        }
        # flash[:danger] = subscription.class
        # flash[:success] = subscription

        # #Doing a merge if card value is updated. Below function will check this
        options.merge!(
            card_last4: params[:user][:card_last4],
            card_exp_month: params[:user][:card_exp_month],
            card_exp_year: params[:user][:card_exp_year],
            card_type: params[:user][:card_type]
            ) if params[:user][:card_last4]
            current_user.update(options)
        
        #Let's add subscription value to the Library... will need to make sure dependencies operating correctly.
        subscription_plans = PlanType.all
        #Took the function out and put it in it's own function in private
        plan_type = find_plan(plan, subscription_plans)
        current_user.plan_subscription_library_additions << plan_type
        # flash[:warning] = params
        #Trigger Flash & The action mailers for confirmation
        OrderConfirmationMailer.customer_confirmation(current_user, plan.nickname, 
            params[:payment_shipping][:recipient_name], params[:payment_shipping][:street_address_1],
            params[:payment_shipping][:street_address_2], params[:payment_shipping][:city],
            params[:payment_shipping][:state], params[:payment_shipping][:zipcode]).deliver_now
        #Hit the order confirmation and send over to the vendor... need to pull the vendor email
        #from Stripe, but question becomes how to test for that.
        #OrderConfirmationMailer.vendor_confirmation(current_user)

        #Redirect back to the root Path and send flash notice
        redirect_to root_path
        flash[:success] = "Your subscription is now active! Please check your email for a confirmation notice."
        # flash[:warning] = params[:plan]
        # flash[:notice] = params

    end

    #We have some work here - not properly deleting as of now
    def destroy
        Stripe.api_key = Rails.application.credentials.development[:stripe_api_key]
        customer = Stripe::Customer.retrieve(current_user.stripe_id)
        #Find the current subscription that we're going to delete
        plan_id = params[:plan_id]
        #Are we pulling the ID from the params section
        flash[:warning] = plan_id
        # subscription = customer.subscriptions.retrieve(plan: plan_id)

        #Remove from the user's library additions
        # subscription_plans = PlanType.all
        # plan_type = find_plan(subscription, subscription_plans)
        # flash[:success] = plan_type
        # current_user.plan_subscription_library_additions.delete(plan_type)

        # #Delete the subscription from stripe and from the user... re-examine this first line
        # customer.subscriptions.retrieve(subscription.id).delete
        # current_user.update(stripe_subscription_id: nil)
        # current_user.subscribed = false

        redirect_to subscription_library_index_path, notice: "Your subscription has been cancelled"
    end

    private

    def find_plan(stripe_subscription, subscription_plans)
        subscription_plans.each do |plan_type|
            if stripe_subscription.nickname.downcase == plan_type.name.downcase
                return plan_type
            end
        end
    end
end
