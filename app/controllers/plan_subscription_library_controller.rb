class PlanSubscriptionLibraryController < ApplicationController
    before_action :logged_in?
    def index
        @plan_library = current_user.plan_subscription_library_additions
        flash[:warning] = params
    end
end