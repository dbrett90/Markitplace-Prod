class CartsController < ApplicationController

    def add_to_cart
        item = params[:one_off_product]
        # flash[:danger] = item
        if cart_empty?
            # empty_cart = Cart.create(products: [])
            current_user.cart.create(products: [item])
            flash[:warning]= "Went through the right way"
        else
            current_user.cart.products << item
            flash[:warning] = "Adding Item!"
        end
        flash[:success] = "Item has been added to your shopping cart!"
        # flash[:danger] = params
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