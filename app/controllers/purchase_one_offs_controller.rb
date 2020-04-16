class PurchaseOneOffsController < ApplicationController 
    def new
        #Give access to all plan types
        @one_off_products = OneOffProduct.all
    end

    def create
    end

    #Do we want this ability to cancel orders in the code?
    def destroy
    end


end