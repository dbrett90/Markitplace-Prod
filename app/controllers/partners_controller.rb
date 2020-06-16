class PartnersController < ApplicationController
    def index
        @partners = PartnerLogo.all
        redirect_to partner_logos_path
    end

    def show
        name_downcase = params[:name].downcase
        @one_off = find_one_off_by_name(name_downcase)
    end

    private
    def find_one_off_by_name(item)
        OneOffProduct.where(:name.downcase => item)
    end

    def find_plan_type_by_name(item)
        PlanType.where(:name => item)
    end
end