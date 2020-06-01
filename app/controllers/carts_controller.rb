class CartsController < ApplicationController

    def index
        if cart_not_created?
            redirect_to root_path
            flash[:warning] = "Your Cart is currently empty!"
        elsif cart_empty?
            redirect_to root_path
            flash[:warning] = "Your Cart is currently empty!"
        else
            @cart_items = current_user.cart.one_off_products
        end 
    end

    def add_to_cart
        item = params[:one_off_product]
        one_off = find_one_off(item)
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

    def destroy
        item = params[:one_off_product]
        one_off = find_one_off(item)
        flash[:warning] = params
        flash[:danger] = one_off
        current_user.cart.one_off_products.delete(one_off)
        flash[:success] = "item has been removed from your cart"
        redirect_to root_path
    end

    def checkout
        @cart_items = current_user.cart.one_off_products
        @total_price = sum_price(current_user.cart.one_off_products)
        #flash[:success] = total_price
    end


    def new
    end

    def create
    end

    private

    def cart_not_created?
        if current_user.cart != nil
            false
        else
            true
        end
    end

    def cart_empty?
        product_length = current_user.cart.one_off_products.length 
        if product_length < 1
            return true
        else
            return false
        end
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



end