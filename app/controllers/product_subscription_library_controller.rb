class ProductSubscriptionLibraryController < ApplicationController
    before_action :logged_in_user
    def index
        @product_library = current_user.product_subscription_library_additions
    end
end