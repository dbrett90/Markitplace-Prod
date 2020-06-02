class CartsController < ApplicationController

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
        item = params[:one_off_product]
        one_off = find_one_off_by_name(item)
        # flash[:danger] = item
        if cart_not_created?
            # empty_cart = Cart.create(products: [])
            current_user.cart.create(products: [])
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

    def add_to_cart_subscription
        item = params[:plan_type]
        plan_type = find_plan_type_by_name(item)
        if cart_not_created?
            # empty_cart = Cart.create(products: [])
            current_user.cart.create(products: [])
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

    def destroy
        if params[:one_off_product] == nil
            item = params[:plan_type]
            plan_type = find_plan_type_by_name(item)
            current_user.cart.plan_types.delete(lan_type)
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
        token = params[:stripeToken]
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
        current_user.cart.one_off_products.delete_all
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



end