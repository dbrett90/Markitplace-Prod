class PartnersController < ApplicationController
    def index
        @partners = PartnerLogo.all
        redirect_to partner_logos_path
    end

    def show
        flash[:warning] = params
    end
end