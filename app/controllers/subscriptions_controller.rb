class SubscriptionsController < ApplicationController    
    def new
        @plans = PlanType.all
    end

    #Bit of an ugly controller - might need to change this to make it more concise
    def create
        #Make sure we change this to production when the time comes
        Stripe.api_key = Rails.application.credentials.development[:stripe_api_key]

        plan_name = params[:plan_name]
        token = params[:stripeToken]
        #Let's add subscription value to the Library.
        subscription_plans = PlanType.all

        plan_type = find_plan(plan_name, subscription_plans)
        fee_value = dyanmic_app_fee(plan_type)
        plan_id = plan_type.plan_type_id
        
        plan = Stripe::Plan.retrieve(plan_id, {stripe_account: plan_type.stripe_id})
        connected_acct = plan_type.stripe_id
        zipcode_val = params[:payment_shipping][:zipcode]
        zipcode_val = zipcode_val.to_s
        # flash[:warning] = zipcode_val
        zipcode_list = parse_zipcodes(plan_type)
        if limit_zipcodes(zipcode_val, zipcode_list)
            customer = if current_user.stripe_id[connected_acct].present?
                Stripe::Customer.retrieve(current_user.stripe_id[connected_acct], {stripe_account: plan_type.stripe_id})
                # flash[:danger] = "User already has a stripe ID!"
            else
                #Create customer in connected accounts environment.
                Stripe::Customer.create({
                    email: current_user.email, 
                    source:token,
                },
                {
                    stripe_account: plan_type.stripe_id,
                })
                # Stripe::Customer.create(description: 'Test Customer')
                #Save the stripe id to the database
            end
            # flash[:success] = customer
            #Update the account with stripe_account id
            current_user.stripe_id[connected_acct] = customer.id
            options = {
                subscribed: true
            }

            #Add the plan_type to the subscription library so it shows up on the user's console
            current_user.plan_subscription_library_additions << plan_type

            #Doing a merge if card value is updated. Below function will check this
            options.merge!(
                card_last4: params[:user][:card_last4],
                card_exp_month: params[:user][:card_exp_month],
                card_exp_year: params[:user][:card_exp_year],
                card_type: params[:user][:card_brand]
                ) if params[:user][:card_last4]

            #Update the subscription creation with stripe connected account param & application_fee_percent params. Sent via connect
            #subscription = customer.subscriptions.create(plan.id, {stripe_account: plan_type.stripe_id})
            subscription = Stripe::Subscription.create({
                customer: customer,
                items: [
                    {
                        plan: plan_id
                    }
                ],
                application_fee_percent: fee_value,
                # application_fee: 0.50,
            }, stripe_account: plan_type.stripe_id)
            # #Update the hash
            current_user.stripe_subscription_id[plan.nickname.downcase] = subscription.id
            current_user.update(options)
            #For the hash portion
            current_user.save

            # flash[:success] = customer

            #Trigger Flash & The action mailers for confirmation
            OrderConfirmationMailer.customer_confirmation(current_user, plan.nickname, 
                params[:payment_shipping][:recipient_name], params[:payment_shipping][:street_address_1],
                params[:payment_shipping][:street_address_2], params[:payment_shipping][:city],
                params[:payment_shipping][:state], params[:payment_shipping][:zipcode]).deliver_now

            #Hit the order confirmation and send over to the vendor... Sends them a confirmation email about the order type. Can also view it in the stripe dashboard
            stripe_connect_users = StripeConnectUser.all
            sc_user_email = find_sc_user_email(stripe_connect_users, plan_type.stripe_id)
            OrderConfirmationMailer.vendor_confirmation(current_user, sc_user_email, plan_type, params[:payment_shipping][:recipient_name], params[:payment_shipping][:street_address_1],
                params[:payment_shipping][:street_address_2], params[:payment_shipping][:city],
                params[:payment_shipping][:state], params[:payment_shipping][:zipcode]).deliver_now

            # #Redirect back to the root Path and send flash notice
            redirect_to root_path
            flash[:success] = "Your subscription is now active! Please check your email for a confirmation notice."
        else
            # stripped_name = strip_spaces(plan_type.name.downcase)
            symbolize = plan_type.name.downcase
            symbolize = symbolize.to_sym
            redirect_to new_subscription_path(plan: plan_type.name.downcase, plan_id: Rails.application.credentials.development.dig(symbolize), plan_name: plan_type.name.downcase )
            flash[:danger] = "Zip code invalid. Delivery services are currently limited to " + plan_type.city_delivery + " for this product"
        end
    end

    #Method to unsubscribe from a current subscription in Stripe
    def destroy
        Stripe.api_key = Rails.application.credentials.development[:stripe_api_key]
        connected_acct = params[:connected_acct]
        customer = Stripe::Customer.retrieve(current_user.stripe_id[connected_acct], {stripe_account: connected_acct})

        # #Are we pulling the ID from the params section - doesn't grab anything currently
        # plan_type = PlanType.find(params[:id])
        # plan_type_downcased = plan_type.name.downcase

        # #Add the plan name and subscription ID as a hash to the subscription id table
        subscription_id = params[:plan_id]
        subscription = customer.subscriptions.retrieve(subscription_id, {stripe_account: connected_acct})

        #Remove from the user's library additions. May need to refactor to be more efficient later on...
        subscription_plans = PlanType.all

        # # Call function to find removed plan
        removed_plan = remove_plan(subscription_plans, subscription.plan.nickname)

        # # #Delete the subscription from stripe and from the user...
        # customer.subscriptions.retrieve(subscription.id).delete
        subscription.delete
        current_user.stripe_subscription_id.delete(subscription.plan.nickname)
        current_user.plan_subscription_library_additions.delete(removed_plan)
        current_user.subscribed = still_subscribed?(current_user)
        # #make sure to save the user to the database
        current_user.save

        redirect_to plan_subscription_library_index_path, notice: "Your subscription has been cancelled"
    end

    private

    #For create controller method
    def find_plan(stripe_subscription, subscription_plans)
        subscription_plans.each do |plan_type|
            if stripe_subscription == plan_type.name.downcase
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

    def find_sc_user_email(sc_users, stripe_id)
        sc_users.each do |sc_user|
            if sc_user.stripe_id == stripe_id
                return sc_user.stripe_email
            end
        end
    end

    def limit_zipcodes(zipcode, zipcode_list)
        #Going to need to build this into the model too
        #available_cities = ["brooklyn", "new york city", "bronx", "queens", "brookline"]
        if zipcode_list.length == 0
            return true
        else
            shipping_address = ZipCodes.identify(zipcode)
            shipping_city = shipping_address[:city]
            shipping_city = shipping_city.downcase
            # flash[:success] = shipping_city
            # flash[:warning] = zipcode_list
            # flash[:warning] = shipping_city
            # shipping_address_down = shipping_address.downcase
            zipcode_list.include?(shipping_city)
        end
    end

    def strip_spaces(keyword)
        keyword.gsub!(/\s/,'_')
    end

    #Need to change this value here to reflect app fee changes
    def dyanmic_app_fee(plan_type)
        fee_binary = plan_type.is_trial.downcase
        if fee_binary == "yes"
            fee_value = 0
        else
            fee_value = 10
        end
    end

    def parse_zipcodes(plan_type)
        zipcode_list = plan_type.city_delivery
        if zipcode_list.nil?
            return []
        else 
            zipcode_list = zipcode_list.split(',')
            zipcode_list= zipcode_list.map do |city|
                city.gsub(/\s+/, '')
            end
            return zipcode_list
        end
    end


end
