class CartsController < ApplicationController
    layout "test", only: [:post_checkout]

    #Need to build in code to modify the number of items you want in a cart
    def checkout
        @cart_items = current_user.cart.one_off_products
        @cart_items_subscriptions = current_user.cart.plan_types
        @total_price = sum_price(current_user.cart.one_off_products) + sum_price(current_user.cart.plan_types)
        # @intent = 
    end

    def guest_cart_index
        if logged_in?
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
        else
            # if guest_cart_empty?
            #     redirect_to root_path
            #     flash[:warning] = "Your Cart is currently empty!"
            #     return
            # else
            if guest_cart.one_off_products == nil
                redirect_to root_path
                flash[warning] = "Cart is empty!"
                return
            elsif guest_cart.one_off_products.length < 1
                redirect_to root_path
                flash[:warning] = "Cart is empty!"
            else
                @cart_items = guest_cart.one_off_products
            end
            # redirect_to root_path
            # flash[:warning] = "Guest!"
            # end
        end
    end

    #Let's test the guest checkout
    def guest_checkout
        @cart_items = guest_cart.one_off_products
        @total_price = sum_price(guest_cart.one_off_products)
    end

    def index
        Stripe.api_key = Rails.application.credentials.production[:stripe_api_key]
        token = params[:stripeToken]
        if logged_in?
            if cart_not_created?
                redirect_to root_path
                # flash[:danger] = "cart not created"
                flash[:warning] = "Your Cart is currently empty!"
            elsif cart_empty?
                redirect_to root_path
                # flash[:danger] = "Nothing in cart"
                flash[:warning] = "Your Cart is currently empty!"
            else
                @cart_items = current_user.cart.line_items
            end 
        else
            if guest_cart.line_items == nil
                redirect_to root_path
                flash[:warning] = "Cart is empty!"
                return
            elsif guest_cart.line_items.length < 1
                redirect_to root_path
                flash[:warning] = "Cart is empty!"
            else
                @cart_items = guest_cart.line_items
            end
        end
        #Check to see if anyting in cart and then create session
        if @cart_items != nil
            #Then create the stripe call
            line_items_array = Array.new() 
            @cart_items.each do |line_item|
                if line_item.flavor_option == nil
                    line_item.flavor_option = ""
                end
                meal_kit = find_one_off_by_id(line_item.product_id)
                item_hash = {
                    price_data: {
                    currency: 'usd',
                    product_data: {
                        name: meal_kit.name + "-"+ line_item.flavor_option,
                    },
                    #Should this be to_i? Revisit
                    unit_amount: (meal_kit.price.to_i)*100,
                    },
                    quantity: line_item.quantity,
                }
                line_items_array << item_hash
            end
            #Initiate Stripe Session Call
            session_id = request.session_options[:id]
            #THIS IS NOT DRY CODE. NEED TO IMPROVE
            if logged_in?
                session = Stripe::Checkout::Session.create(
                    #Customer email is only paramter changed
                    customer_email: current_user.email,
                    payment_method_types: ['card'],
                    shipping_address_collection: {
                        allowed_countries: ['US'],
                    },
                    line_items: line_items_array,
                    mode: 'payment',
                    success_url: "https://www.markitplace.io/successful-checkout?session_id=#{session_id}",
                    cancel_url: 'https://www.markitplace.io/unsuccessful-checkout',
                )
            else
                session = Stripe::Checkout::Session.create(
                    payment_method_types: ['card'],
                    shipping_address_collection: {
                        allowed_countries: ['US'],
                    },
                    line_items: line_items_array,
                    mode: 'payment',
                    success_url: "https://www.markitplace.io/successful-checkout?session_id=#{session_id}",
                    cancel_url: 'https://www.markitplace.io/unsuccessful-checkout',
                )
            end
            @session = session
        end
    end

    def successful_checkout
        if user_signed_in?
            current_user.cart.line_items.delete_all
        else
            guest_cart.line_items.delete_all
            # flash[:warning] = guest_cart.line_items
        end
        #OrderConfirmationMailer.single_kit_order.deliver_now
        flash[:success] = "Your order has been received! You will receive an email confirmation shortly."
        redirect_to root_path
    end

    def unsuccessful_checkout
        flash[:danger] = "Your checkout session didn't complete. Please try again"
        redirect_to cart_path
    end

    #Method specifically for guests adding to cart

    #Modify specifically for tge sauce. Not good long term
    def guest_add_to_cart
        item = (params[:one_off_product]).downcase
        one_off = find_one_off(item)
        # flash[:success] = guest_cart
        # @cart guest_cart
        if one_off.out_of_stock == nil || one_off.out_of_stock != "yes"
            guest_cart.one_off_products << one_off
            guest_cart.save
            flash[:success] = "Item has been added to your shopping cart!"
            redirect_to one_off_products_path
        else
            flash[:warning] = "Unfortunately this item is out of stock. Please try another!"
            redirect_to one_off_products_path
        end
    end

    def post_guest_add_to_cart
        item = (params[:one_off_product]).downcase
        one_off = find_one_off(item)
        #update the sauce - this will need to be changed
        # flash[:warning] = params[:sauce]
        if one_off.id == 80 || one_off.id == 81 || one_off.id == 82 || one_off.id == 84
            one_off.add_on = params[:sauce][:sauce_choice]
            one_off.save
        end
        # @cart guest_cart
        if one_off.out_of_stock == nil || one_off.out_of_stock != "yes"
            guest_cart.one_off_products << one_off
            guest_cart.save
            flash[:success] = "Item has been added to your shopping cart!"
            redirect_to one_off_products_path
        else
            flash[:warning] = "Unfortunately this item is out of stock. Please try another!"
            redirect_to one_off_products_path
        end
    end

    #Run on the local server first --> Need to test
    def add_to_cart
        item = params[:one_off_product]
        #Specify quantity when adding to cart --> Need to add to form
        quantity = (params[:item_options][:quantity]).to_i
        if quantity == 0
            quantity = 1
        end
        #Probably should change this to ID
        one_off = find_one_off_by_id(item)
        # flash[:danger] = params[:quantity]
        line_item = LineItem.new()
        line_item.product_id = item
        if one_off.flavor_options != "" && one_off.flavor_options != nil
            flavor_array = params[:item_options][:flavor_option]
            flavor_string = ""
            flavor_array.each do |flavor|
                flavor_string += flavor
                flavor_string+= ", "
            end
            flavor_string = flavor_string[0..-3]
            line_item.flavor_option = flavor_string
            # flash[:warning] = flavor_string
        end
        line_item.quantity = quantity
        line_item.product_type = "One Off Product"
        if logged_in?
            if cart_not_created?
                testCart = Cart.new()
                current_user.cart = testCart
            end
            current_user.cart.line_items << line_item
            current_user.cart.save
        #If user is a guest
        else
            guest_cart.line_items << line_item
            guest_cart.save
        end
        flash[:success] = "Item has been added to your shopping cart!"
        redirect_to one_off_products_path
    end

    def post_add_to_cart
        item_id = params[:one_off_product]
        if params[:quantity][:quantity] == nil
            quantity = 1
        else
            quantity = (params[:quantity][:quantity]).to_i
        end
        # quantity = quantity.to_i
        # flash[:danger] = quantity
        one_off = find_one_off_by_id(item_id)
        if one_off.out_of_stock == nil
            if cart_not_created?
                testCart = Cart.new()
                current_user.cart = testCart
            end
        # elsif one_off.out_of_stock.downcase == "yes"
        #     flash[:warning] = "Unfortunately this item is out of stock. Please try another!"
        #     redirect_to one_off_products_path
        #     return
        else
            if cart_not_created?
                # empty_cart = Cart.create(products: [])
                testCart = Cart.new()
                current_user.cart = testCart
            end 
        end
        #Instantiate Line Item
        line_item = LineItem.new()
        line_item.product_id = item_id
        line_item.quantity = quantity
        line_item.product_type = "One Off Product"
        #Add Line Item to Cart & Save
        current_user.cart.line_items << line_item
        current_user.cart.save
        flash[:success] = "Item has been added to your shopping cart!"
        redirect_to one_off_products_path
    end

    def post_index
        @cart_items = current_user.cart.line_items
    end

    #When subscriptions come into play need to update?
    def post_destroy
        product_id = params[:product_id]
        product_type = params[:product_type]
        line_item = LineItem.where(product_id: product_id).where(product_type: product_type)
        current_user.cart.line_items.delete(line_item)
        redirect_to test_index_path
    end

    def post_checkout
        @cart_items = current_user.cart.line_items
        @total_price = sum_line_item_price(current_user.cart.line_items)
    end

    def post_complete_checkout
        #Need to update the test layout here
        # render :layout => 'test_layout'
        #Make sure we change this to production when the time comes
        Stripe.api_key = Rails.application.credentials.development[:stripe_api_key]
        @cart_items = current_user.cart.line_items
        token = params[:stripeToken]

        #Complete Checkout for Subscriptions
        @cart_items.each do |item|
            if item.product_type != "One Off Product"
                #Declare Variables up front
                plan_type = find_plan_type_by_id(item.product_id)
                fee_value = dynamic_app_fee(plan_type)
                plan_id = plan_type.plan_type_id
                plan = Stripe::Plan.retrieve(plan_id, {stripe_account: plan_type.stripe_id})
                connected_acct = plan_type.stripe_id
                #Is Zip Code Ok? If so proceed
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
            else 
                item = find_one_off_by_id(item.product_id)
                fee_amount = dynamic_app_fee(item)
                changed_price = item.price * 100
                unless fee_amount == 0
                    fee_amount = (changed_price * fee_amount).to_i
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
                        #customer: customer,
                        transfer_data: {
                            destination: item.stripe_id,
                        },
                    })
                end
                #Make it available to the user
                # @intent = payment_intent
                flash[:danger] = payment_intent.customer
                card_brand = (params[:user][:card_brand]).downcase
                flash[:warning] = params[:user]
                payment_method_card = 'pm_card_' + card_brand
                # flash[:danger] = payment_method_card
                confirm_payment = Stripe::PaymentIntent.confirm(
                    payment_intent.id,
                    {payment_method: payment_method_card},
                )
                current_user.one_off_id[item.name.downcase] = payment_intent.id
                current_user.update(options)
                #For the hash portion
                current_user.save
            end
            #Send out the confirmation emails
            #Trigger Flash & The action mailers for confirmation
            # OrderConfirmationMailer.customer_order_confirmation(current_user,
            # params[:payment_shipping][:recipient_name], params[:payment_shipping][:street_address_1],
            # params[:payment_shipping][:street_address_2], params[:payment_shipping][:city],
            # params[:payment_shipping][:state], params[:payment_shipping][:zipcode]).deliver_now

            # # #Hit the order confirmation and send over to the vendor(s)... Sends them a confirmation email about the order type. Can also view it in the stripe dashboard
            # stripe_connect_users = StripeConnectUser.all
            # sc_user_email_hash = post_find_sc_user_email(stripe_connect_users, current_user.cart.line_items)
            # sc_user_email_hash.each do |vendor_email, product_array|
            #     OrderConfirmationMailer.vendor_order_confirmation(current_user, params[:payment_shipping][:recipient_name], vendor_email, product_array, params[:payment_shipping][:street_address_1],
            #     params[:payment_shipping][:street_address_2], params[:payment_shipping][:city],
            #     params[:payment_shipping][:state], params[:payment_shipping][:zipcode]).deliver_now
            # end 


            #Confirm that the orders were made and notify customers on webpage
            flash[:success] = "Thank you for your Purchase! You will receive
            an email with a confirmation notice shortly."
            current_user.cart.line_items.delete_all
            redirect_to root_path
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

    def guest_destroy
        if params[:one_off_product] == nil
            item = params[:plan_type]
            plan_type = find_plan_type_by_name(item)
            guest_cart.plan_types.delete(plan_type)
        else
            item = params[:one_off_product]
            one_off_by_name = find_one_off_by_name(item)
            guest_cart.one_off_products.delete(one_off_by_name)
        end
        #It's pulling all the items in the cart here.
        flash[:success] = "Item has been removed from your cart"
        redirect_to guest_cart_path
    end


    def destroy
        item = params[:one_off_product]
        one_off_by_name = LineItem.find(item)
        if logged_in?
            current_user.cart.line_items.delete(one_off_by_name)
        else
            guest_cart.line_items.delete(one_off_by_name)
        end
        #It's pulling all the items in the cart here.
        flash[:success] = "Item has been removed from your cart"
        redirect_to cart_path
    end

    def complete_checkout
        #Make sure we change this to production when the time comes
        Stripe.api_key = Rails.application.credentials.production[:stripe_api_key]
        @cart_items = current_user.cart.one_off_products
        @cart_items_subscriptions = current_user.cart.plan_types
        token = params[:stripeToken]
        # source = paras[:stripeSource]

        #Complete Checkout for Subscriptions
        @cart_items_subscriptions.each do |plan_type|
            fee_value = dynamic_app_fee(plan_type)
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
                        source: token,
                    },
                    {
                        stripe_account: plan_type.stripe_id,
                    })
                    # Stripe::Customer.create(description: 'Test Customer')
                    #Save the stripe id to the database
                end
                #Link the platform IDs here.
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
            fee_amount = dynamic_app_fee(item)
            changed_price = item.price * 100
            unless fee_amount == 0
                fee_amount = (changed_price * fee_amount).to_i
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
                    source: token,
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
                    confirm: true,
                    currency: 'usd',
                    application_fee_amount: fee_amount,
                    capture_method: 'automatic',
                    confirmation_method: 'automatic',
                    customer: customer.id,
                    #on_behalf_of: item.stripe_id,
                    transfer_data: {
                        destination: item.stripe_id,
                    },
                })
            else
                payment_intent = Stripe::PaymentIntent.create({
                    payment_method_types: ['card'],
                    # payment_method: params[:user][:card_id],
                    amount: (item.price*100).to_i,
                    currency: 'usd',
                    #Confirm set to true
                    confirm: true,
                    capture_method: 'automatic',
                    confirmation_method: 'automatic',
                    customer: customer.id,
                    }, {
                        stripe_account: item.stripe_id, 
                })
            end
            @payment_intent_id = payment_intent.client_secret
            @js_user_name = params[:payment_shipping][:recipient_name]
            gon.payment_intent_id = @payment_intent_id
            gon.js_user_name = @js_user_name
            # flash[:warning] = gon.payment_intent_id
            # get '/secret' do
            #     {client_secret: payment_intent.client_secret}.to_json
            # end

            # card_brand = (params[:user][:card_brand]).downcase
            ####RETURN TO THIS
            # customer = Stripe::Customer.update(
            #     customer.id,
            #     source: token,
            #     {
            #         stripe_account: item.stripe_id,
            #     }
            # )
            payment_method_card = params[:user][:card_id]
            payment_method = params[:user][:payment_method]
            # source = Stripe::Customer.retrieve_source(
            #     customer.id,
            #     payment_method,
            # )
            # flash[:warning] = @payment_intent
            # flash[:danger] = params[:user]
            # payment_method = Stripe::PaymentMethod.create({
            #     customer: customer.id,
            #     payment_method: payment_method_card,
            # }, {
            #     stripe_account: item.stripe_id
            # })
            # confirm_payment = Stripe::PaymentIntent.confirm(
            #     payment_intent.id,
            #     {payment_method: payment_method},
            #     {stripe_account: item.stripe_id},
            # )
    
            ##NEED TO CONFIRM THE PAYMENT AFTER THE FACT! CHECK THE DOCS FOR THIS
    
            #May need to change one_off_id for naming conventionRENAME
            # current_user.one_off_id[item.name.downcase] = payment_intent.id
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


        #Confirm that the orders were made and notify customers on webpage
        flash[:success] = "Thank you for your Purchase! You will receive
        an email with a confirmation notice shortly."
        current_user.cart.one_off_products.delete_all
        current_user.cart.plan_types.delete_all
        redirect_to root_path
    end

    #Test this first with development key
    def guest_complete_checkout
        #Must ensure that the proper layout with development keys are used. Check the post
        #checkout headers for example
        #Make sure we change this to production when the time comes
        Stripe.api_key = Rails.application.credentials.production[:stripe_api_key]
        @cart_items = guest_cart.one_off_products
        token = params[:stripeToken]

     
        
        #Save values to guest db
        guest_name = params[:payment_shipping][:recipient_first_name] + " " + params[:payment_shipping][:recipient_last_name]
        guest_user = GuestUser.new
        guest_user.name = guest_name
        guest_user.email = params[:payment_shipping][:recipient_email]
        guest_user.phone_number = params[:payment_shipping][:recipient_phone_number]
        guest_user.save
        

        #flash[:success] = @cart_items
        @cart_items.each do |item|
            #Do zip code validation
            city_list = parse_list(item)
            if delivery_city_ok?(city_list, params[:payment_shipping][:city])
                fee_amount = dynamic_app_fee(item)
                changed_price = item.price * 100
                unless fee_amount == 0
                    fee_amount = (changed_price * fee_amount).to_i
                else
                    fee_amount = 0
                end
                connected_acct = item.stripe_id
                
                #No customer exists, needs to create a new one
                customer = Stripe::Customer.create({
                    email: params[:payment_shipping][:recipient_email], 
                    source: token,
                },
                {
                    stripe_account: item.stripe_id,
                })

                if charge_app_fee?(fee_amount)
                    payment_intent = Stripe::PaymentIntent.create({
                        payment_method_types: ['card'],
                        amount: (item.price*100).to_i,
                        confirm: true,
                        currency: 'usd',
                        application_fee_amount: fee_amount,
                        capture_method: 'automatic',
                        confirmation_method: 'automatic',
                        customer: customer.id,
                        transfer_data: {
                            destination: item.stripe_id,
                        },
                    })
                else
                    payment_intent = Stripe::PaymentIntent.create({
                        payment_method_types: ['card'],
                        amount: (item.price*100).to_i,
                        currency: 'usd',
                        #Confirm set to true
                        confirm: true,
                        capture_method: 'automatic',
                        confirmation_method: 'automatic',
                        customer: customer.id,
                        }, {
                            stripe_account: item.stripe_id, 
                    })
                end
            else
                redirect_to guest_cart_path 
                flash[:warning] = "There is an item in your cart that does not deliver to the provided address. Please remove it"
                return
            end
        end
        #REVISIT HERE - ORDER CONFIRMATION
        
        #Send out the confirmation emails - need to modify for guests
        #Trigger Flash & The action mailers for confirmation
        OrderConfirmationMailer.guest_customer_order_confirmation(params[:payment_shipping][:recipient_first_name],
        params[:payment_shipping][:recipient_last_name], params[:payment_shipping][:recipient_email], @cart_items, params[:payment_shipping][:street_address_1],
        params[:payment_shipping][:street_address_2], params[:payment_shipping][:city],
        params[:payment_shipping][:state], params[:payment_shipping][:zipcode]).deliver_now

        #  # #Hit the order confirmation and send over to the vendor(s)... Sends them a confirmation email about the order type. Can also view it in the stripe dashboard
        #Test the guest checkout 
        stripe_connect_users = StripeConnectUser.all
        sc_user_email_hash = guest_find_sc_user_email(stripe_connect_users, guest_cart.one_off_products)
        sc_user_email_hash.each do |vendor_email, product_array|
            OrderConfirmationMailer.guest_vendor_order_confirmation(params[:payment_shipping][:recipient_first_name], params[:payment_shipping][:recipient_last_name], params[:payment_shipping][:recipient_email], params[:payment_shipping][:recipient_phone_number], vendor_email, guest_cart.one_off_products, params[:payment_shipping][:street_address_1],
            params[:payment_shipping][:street_address_2], params[:payment_shipping][:city],
            params[:payment_shipping][:state], params[:payment_shipping][:zipcode]).deliver_now
        end 

        #Send out the recipes via embedded PDF
        # checkout_items = guest_cart.one_off_products
        # checkout_items.each do |item|
        #     if item.recipe_instructions_link != nil
        #         OrderConfirmationMailer.recipe_instructions(params[:payment_shipping][:recipient_first_name],
        #         params[:payment_shipping][:recipient_last_name], params[:payment_shipping][:recipient_email], item).deliver_now
        #     end
        # end

        #Remove all products from Cart
        guest_cart.one_off_products.delete_all 
        #Confirm that the orders were made and notify customers on webpage
        flash[:success] = "Thank you for your Purchase! You will receive an email with a confirmation notice shortly."
        #NEED TO WIPE THE GUEST CART CLEAN HERE... @CART = nil?
        redirect_to root_path
    end


    def new
    end

    def create
    end

    def test_email
        # OrderConfirmationMailer.test_order_confirmation().deliver_now
        # redirect_to root_path
        #Prerequisite libraries
        # require 'sendgrid-ruby'
        # include SendGrid
        # flash[:success] = "Email sent?"
        from = Email.new(email: 'no-reply@markitplace.io')
        to = Email.new(email: 'danbrett107@gmail.com')
        subject = 'Sending with SendGrid is Fun'
        content = Content.new(type: 'text/plain', value: 'and easy to do anywhere, even with Ruby')
        mail = Mail.new(from, subject, to, content)

        sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
        response = sg.client.mail._('send').post(request_body: mail.to_json)
        puts response.status_code
        puts response.body
        puts response.headers
        redirect_to root_path
        flash[:success] = "Email Sent by SendGrid"
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
        # product_length = current_user.cart.one_off_products.length 
        # subscription_length = current_user.cart.plan_types.length
        if current_user.cart.line_items.length < 1
            return true
        else
            return false
        end
    end

    def guest_cart_empty?
        num_items = guest_cart.one_off_products
        if num_items != nil 
            num_items = num_items.length
        else
            num_items = 0
        end
        #based on previous values
        if num_items < 1 
            return true
        else
            return false
        end
    end

    def find_one_off_by_name(item)
        OneOffProduct.where(:name => item)
    end

    def find_one_off_by_id(id)
        OneOffProduct.find(id)
    end
    helper_method :find_one_off_by_id

    def find_plan_type_by(id)
        PlanType.find(id)
    end
    helper_method :find_plan_type_by_id

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

    def sum_line_item_price(line_items)
        sum_price = 0
        line_items.each do |line_item|
            #Parameterize One Off Product? Spelling issue here breaks everything
            if line_item.product_type == "One Off Product"
                one_off = OneOffProduct.find(line_item.product_id)
                sum_price += one_off.price
            else
                subscription = PlanType.find(line_item.product_id)
                sum += subscription.price
            end
        end
        sum_price
    end

    def dynamic_app_fee(one_off)
        fee_binary = one_off.is_trial.downcase
        if fee_binary == "yes"
            fee_value = 0.00
        else
            fee_value = 0.05
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

    def guest_find_sc_user_email(sc_users, one_off_products)
        email_list = Hash.new{|hsh,key| hsh[key] = [] }
        sc_users.each do |sc_user|
            one_off_products.each do |one_off|
                if sc_user.stripe_id == one_off.stripe_id
                    email_list[sc_user.stripe_email] <<  one_off.name
                end
            end
        end
        email_list
    end

    def post_find_sc_user_email(sc_users, line_items)
        email_list = Hash.new{|hsh,key| hsh[key] = [] }
        sc_users.each do |sc_user|
            line_items.each do |line_item|
                if line_item.product_type == "One Off Product"
                    one_off = OneOffProduct.find(line_item.product_id)
                    if sc_user.stripe_id == one_off.stripe_id
                        email_list[sc_user.stripe_email] <<  one_off.name
                    end 
                else 
                    plan_type = PlanType.find(line_item.product_id)
                    if sc_user.stripe_id == plan_type.stripe_id
                        combined_string = plan_type.name + " recurring subscription"
                        email_list[sc_user.stripe_email] << combined_string
                    end
                end
            end
        end
        email_list
    end

    #This will work in the short term, but issue if there is a city long term
    #That has some name as one in NY that is not in NY (as example). Zipcode 
    #prefferred validation metric at some point in time

    #First parse the available cities, noting that they need to be separated
    #by commas in the form itself
    def parse_list(one_off_product)
        city_list = one_off_product.available_cities
        if city_list.nil?
            return []
        else 
            city_list = city_list.split(',')
            city_list= city_list.map do |city|
                city.gsub(/\s+/, '')
            end
            return city_list
        end
    end

    def delivery_city_ok?(available_cities_list, shipping_address_city)
        if available_cities_list.length == 0
            return true
        else
            #Assumes the cities input are lowercase
            shipping_address_city = shipping_address_city.downcase
            available_cities_list.include?(shipping_address_city)
        end

    end

end