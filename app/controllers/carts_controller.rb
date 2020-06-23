class CartsController < ApplicationController

    #Need to build in code to modify the number of items you want in a cart
    def checkout
        @cart_items = current_user.cart.one_off_products
        @cart_items_subscriptions = current_user.cart.plan_types
        # flash[:success] = @cart_items
        # @item_price = sum_price(current_user.cart.one_off_products)
        # @sub_price = sum_price(current_user.cart.plan_types)
        #Calculate the total price of the items
        @total_price = sum_price(current_user.cart.one_off_products) + sum_price(current_user.cart.plan_types)
        #flash[:success] = total_price
    end

    def index
        if cart_not_created?
            redirect_to root_path
            flash[:warning] = "Your Cart is currently empty!"
        elsif cart_empty?
            redirect_to root_path
            flash[:warning] = "Your Cart is currently empty!"
        else
            @cart_items = current_user.cart.one_off_products
            @cart_items_subscriptions = current_user.cart.plan_types
        end 
    end

    def add_to_cart
        item = (params[:one_off_product]).downcase
        one_off = find_one_off(item)
        #flash[:danger] = one_off.out_of_stock
        if one_off.out_of_stock == nil
            if cart_not_created?
                # empty_cart = Cart.create(products: [])
                testCart = Cart.new()
                current_user.cart = testCart
                current_user.cart.one_off_products << one_off
                # flash[:warning]= "Went through the right way"
            else
                current_user.cart.one_off_products << one_off
                # flash[:warning] = "Adding Item!"
            end
            current_user.cart.save
            flash[:success] = "Item has been added to your shopping cart!"
            # flash[:danger] = params
            redirect_to one_off_products_path
        elsif one_off.out_of_stock.downcase == "yes"
            flash[:warning] = "Unfortunately this item is out of stock. Please try another!"
            redirect_to one_off_products_path
        else
            if cart_not_created?
                # empty_cart = Cart.create(products: [])
                testCart = Cart.new()
                current_user.cart = testCart
                current_user.cart.one_off_products << one_off
                # flash[:warning]= "Went through the right way"
            else
                current_user.cart.one_off_products << one_off
                # flash[:warning] = "Adding Item!"
            end
            current_user.cart.save
            flash[:success] = "Item has been added to your shopping cart!"
            # flash[:danger] = params
            redirect_to one_off_products_path
        end
    end

    def add_to_cart_subscription
        item = params[:plan_type]
        plan_type = find_plan_type_by_name(item)
        if cart_not_created?
            # empty_cart = Cart.create(products: [])
            #Create an instance of the cart an attach it to a user.
            testCart = Cart.new()
            current_user.cart = testCart
            current_user.cart.plan_types << plan_type
            # flash[:warning]= "Went through the right way"
        else
            current_user.cart.plan_types << plan_type
            # flash[:warning] = "Adding Item!"
        end
        current_user.cart.save
        flash[:success] = "Subscription has been added to your shopping cart!"
        # flash[:danger] = params
        redirect_to plan_types_path

    end

    def update_quantity
    end

    def destroy
        if params[:one_off_product] == nil
            item = params[:plan_type]
            plan_type = find_plan_type_by_name(item)
            current_user.cart.plan_types.delete(plan_type)
        else
            item = params[:one_off_product]
            one_off_by_name = find_one_off_by_name(item)
            current_user.cart.one_off_products.delete(one_off_by_name)
        end
        #It's pulling all the items in the cart here.
        flash[:success] = "Item has been removed from your cart"
        redirect_to cart_path
    end

    def complete_checkout
        #Make sure we change this to production when the time comes
        Stripe.api_key = Rails.application.credentials.development[:stripe_api_key]
        @cart_items = current_user.cart.one_off_products
        @cart_items_subscriptions = current_user.cart.plan_types
        token = params[:stripeToken]

        #Complete Checkout for Subscriptions
        @cart_items_subscriptions.each do |plan_type|
            fee_value = dyanmic_app_fee(plan_type)
            plan_id = plan_type.plan_type_id
            plan = Stripe::Plan.retrieve(plan_id, {stripe_account: plan_type.stripe_id})
            connected_acct = plan_type.stripe_id
            zipcode_val = params[:payment_shipping][:zipcode]
            zipcode_val = zipcode_val.to_s
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
                current_user.stripe_id[connected_acct] = customer.id
                options = {
                    subscribed: true
                }
                current_user.plan_subscription_library_additions << plan_type

                #Doing a merge on cards
                options.merge!(
                card_last4: params[:user][:card_last4],
                card_exp_month: params[:user][:card_exp_month],
                card_exp_year: params[:user][:card_exp_year],
                card_type: params[:user][:card_brand]
                ) if params[:user][:card_last4]

                #Create the subscription
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

                #Update the user hash
                current_user.stripe_subscription_id[plan.nickname.downcase] = subscription.id
                current_user.update(options)
                #For the hash portion
                current_user.save
            else
                 # stripped_name = strip_spaces(plan_type.name.downcase)
                symbolize = plan_type.name.downcase
                symbolize = symbolize.to_sym
                flash[:danger] = "Please note that for this subscription the zip code you provided is invalid. Delivery services are currently limited to " + plan_type.city_delivery + " for this product"
                redirect_to cart_path
                return
            end
        end
        # flash[:success] = @cart_items
        @cart_items.each do |item|
            fee_amount = dyanmic_app_fee(item)
            changed_price = item.price * 100
            unless fee_amount == 0
                fee_amount = (changed_price / fee_amount).to_i
            else
                fee_amount = 0
            end
            connected_acct = item.stripe_id
            # flash[:warning] = item.price         

            #Retrieve Customer
            customer = if current_user.stripe_id[connected_acct].present?
                Stripe::Customer.retrieve(current_user.stripe_id[connected_acct], {stripe_account: item.stripe_id})
            else
                #Create customer in connected accounts environment.
                Stripe::Customer.create({
                    email: current_user.email, 
                    source:token,
                },
                {
                    stripe_account: item.stripe_id,
                })
                # Stripe::Customer.create(description: 'Test Customer')
                #Save the stripe id to the database
            end
            current_user.stripe_id[connected_acct] = customer.id

            options = {
                subscribed: true
            }
    
            options.merge!(
                card_last4: params[:user][:card_last4],
                card_exp_month: params[:user][:card_exp_month],
                card_exp_year: params[:user][:card_exp_year],
                card_type: params[:user][:card_brand]
                ) if params[:user][:card_last4]
    
            if charge_app_fee?(fee_amount)
                payment_intent = Stripe::PaymentIntent.create({
                    payment_method_types: ['card'],
                    amount: (item.price*100).to_i,
                    currency: 'usd',
                    application_fee_amount: fee_amount,
                    capture_method: 'automatic',
                    confirmation_method: 'automatic',
                    # customer: customer,
                    transfer_data: {
                        destination: item.stripe_id,
                    },
                })
            else
                payment_intent = Stripe::PaymentIntent.create({
                    payment_method_types: ['card'],
                    amount: (item.price*100).to_i,
                    currency: 'usd',
                    capture_method: 'automatic',
                    confirmation_method: 'automatic',
                    # customer: customer,
                    transfer_data: {
                        destination: item.stripe_id,
                    },
                })
            end

            # flash[:success] = payment_intent
            #Confirm that the ID is indeed coming through this way
            #flash[:danger] = payment_intent.id
            # card_method_payment = 'pm_card_'+params[:user][:card_brand]
            # flash[:danger] = card_method_payment
            # flash[:warning] = params[:user]
            card_brand = (params[:user][:card_brand]).downcase
            payment_method_card = 'pm_card_' + card_brand
            # flash[:danger] = payment_method_card
            confirm_payment = Stripe::PaymentIntent.confirm(
                payment_intent.id,
                {payment_method: payment_method_card},
            )
    
            ##NEED TO CONFIRM THE PAYMENT AFTER THE FACT! CHECK THE DOCS FOR THIS
    
            #May need to change one_off_id for naming convention
            current_user.one_off_id[item.name.downcase] = payment_intent.id
            current_user.update(options)
            #For the hash portion
            current_user.save
        end

        #Send out the confirmation emails
        #Trigger Flash & The action mailers for confirmation
        OrderConfirmationMailer.customer_order_confirmation(current_user,
        params[:payment_shipping][:recipient_name], params[:payment_shipping][:street_address_1],
        params[:payment_shipping][:street_address_2], params[:payment_shipping][:city],
        params[:payment_shipping][:state], params[:payment_shipping][:zipcode]).deliver_now

        # #Hit the order confirmation and send over to the vendor(s)... Sends them a confirmation email about the order type. Can also view it in the stripe dashboard
        stripe_connect_users = StripeConnectUser.all
        sc_user_email_hash = find_sc_user_email(stripe_connect_users, current_user.cart.one_off_products, current_user.cart.plan_types)
        sc_user_email_hash.each do |vendor_email, product_array|
            OrderConfirmationMailer.vendor_order_confirmation(current_user, params[:payment_shipping][:recipient_name], vendor_email, product_array, params[:payment_shipping][:street_address_1],
            params[:payment_shipping][:street_address_2], params[:payment_shipping][:city],
            params[:payment_shipping][:state], params[:payment_shipping][:zipcode]).deliver_now
        end 
        # OrderConfirmationMailer.vendor_confirmation(current_user, sc_user_email, plan_type, params[:payment_shipping][:recipient_name], params[:payment_shipping][:street_address_1],
        #     params[:payment_shipping][:street_address_2], params[:payment_shipping][:city],
        #     params[:payment_shipping][:state], params[:payment_shipping][:zipcode]).deliver_now


        #Confirm that the orders were made and notify customers on webpage
        flash[:success] = "Thank you for your Purchase! You will receive
        an email with a confirmation notice shortly."
        current_user.cart.one_off_products.delete_all
        current_user.cart.plan_types.delete_all
        redirect_to root_path
    end


    def new
    end

    def create
    end

    private

    def charge_app_fee?(fee_amount)
        if fee_amount == 0
            false
        else
            true
        end
    end

    def cart_not_created?
        if current_user.cart != nil
            false
        else
            true
        end
    end

    def cart_empty?
        product_length = current_user.cart.one_off_products.length 
        subscription_length = current_user.cart.plan_types.length
        if product_length < 1 && subscription_length < 1
            return true
        else
            return false
        end
    end

    def find_one_off_by_name(item)
        OneOffProduct.where(:name => item)
    end

    def find_plan_type_by_name(item)
        PlanType.where(:name => item)
    end

    def find_one_off(item)
        @one_off_products = OneOffProduct.all 
        @one_off_products.each do |product|
            if product.name.downcase == item
                return product 
            end
        end
    end

    def sum_price(cart_items)
        sum_price = 0
        cart_items.each do |item|
            sum_price += item.price 
        end
        return sum_price
    end

    def dyanmic_app_fee(one_off)
        fee_binary = one_off.is_trial.downcase
        if fee_binary == "yes"
            fee_value = 0.0
        else
            fee_value = 10.0
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

    #Generate a hash of all the vendors with confirmation of products
    def find_sc_user_email(sc_users, one_off_products, plan_types)
        email_list = Hash.new{|hsh,key| hsh[key] = [] }
        sc_users.each do |sc_user|
            one_off_products.each do |one_off|
                if sc_user.stripe_id == one_off.stripe_id
                    email_list[sc_user.stripe_email] <<  one_off.name
                end
            end
            plan_types.each do |plan_type| 
                if sc_user.stripe_id == plan_type.stripe_id
                    combined_string = plan_type.name + " recurring subscription"
                    email_list[sc_user.stripe_email] << combined_string
                end
            end
        end
        email_list
    end

end