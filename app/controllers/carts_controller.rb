class CartsController < ApplicationController

    def add_to_cart
        item = params[:one_off_product]
        one_off = find_one_off(item)
        # flash[:danger] = item
        if cart_empty?
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

    def view_cart
        @cart_items = current_user.cart.one_off_products
    end

    def checkout
    end

    def new
    end

    def create
    end

    def destroy
    end

    private

    def cart_empty?
        if current_user.cart != nil
            false
        else
            true
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



end