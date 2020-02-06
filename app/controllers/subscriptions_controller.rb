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
        #Let's add subscription value to the Library.
        subscription_plans = PlanType.all

        #calling private function find_plan
        plan_type = find_plan(plan, subscription_plans)

        #Update the subscription creation with stripe connected account param & application_fee_percent params. Sent via connect
        subscription = customer.subscriptions.create(plan: plan.id, transfer_data{amount_percent:95 destination: plan_type.stripe_id })
        #Update the hash
        current_user.stripe_subscription_id[plan.nickname.downcase] = subscription.id
        options = {
            stripe_id: customer.id,
            subscribed: true
        }
        current_user.plan_subscription_library_additions << plan_type

        # #Doing a merge if card value is updated. Below function will check this
        options.merge!(
            card_last4: params[:user][:card_last4],
            card_exp_month: params[:user][:card_exp_month],
            card_exp_year: params[:user][:card_exp_year],
            card_type: params[:user][:card_type]
            ) if params[:user][:card_last4]
            current_user.update(options)

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

    end

    #Method to unsubscribe from a current subscription in Stripe
    def destroy
        Stripe.api_key = Rails.application.credentials.development[:stripe_api_key]
        customer = Stripe::Customer.retrieve(current_user.stripe_id)

        #Are we pulling the ID from the params section - doesn't grab anything currently
        plan_type = PlanType.find(params[:id])
        plan_type_downcased = plan_type.name.downcase

        #Add the plan name and subscription ID as a hash to the subscription id table
        subscription_id = current_user.stripe_subscription_id[plan_type_downcased]
        subscription = customer.subscriptions.retrieve(id: subscription_id)

        #Remove from the user's library additions. May need to refactor to be more efficient later on...
        subscription_plans = PlanType.all

        # Call function to find removed plan
        removed_plan = remove_plan(subscription_plans, plan_type_downcased)
        current_user.plan_subscription_library_additions.delete(removed_plan)

        # #Delete the subscription from stripe and from the user...
        customer.subscriptions.retrieve(subscription.id).delete
        current_user.stripe_subscription_id.delete(plan_type_downcased)
        current_user.subscribed = still_subscribed?(current_user)
        #make sure to save the user to the database
        current_user.save

        redirect_to plan_subscription_library_index_path, notice: "Your subscription has been cancelled"
    end

    private

    #For create controller method
    def find_plan(stripe_subscription, subscription_plans)
        subscription_plans.each do |plan_type|
            if stripe_subscription.nickname.downcase == plan_type.name.downcase
                return plan_type
            end
        end
    end

    #For delete controller method
    def remove_plan(plans, plan)
        plans.each do |each_plan|
            if each_plan.name.downcase == plan
                return each_plan
            end
        end
    end

    #Is the user still subscribed?
    def still_subscribed?(user)
        if user.stripe_subscription_id.length >=1
            true
        else
            false
        end
    end


end
