class CartsController < ApplicationController

    def add_to_cart
        item = params[:one_off_product]
        if cart_empty?
            empty_cart = Cart.create(products: [])
            current_user.cart = empty_cart
            current_user.cart.products.append(item)
        else
            current_user.cart.products.append(item)
        end
        flash[:success] = "Item has been added to your shopping cart!"
        redirect_to root_path
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



end