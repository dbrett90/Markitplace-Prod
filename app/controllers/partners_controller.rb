class PartnersController < ApplicationController
    def index
        @partners = PartnerLogo.all
        redirect_to partner_logos_path
    end

    def show
        name_downcase = params[:name].downcase
        flash[:success] = name_downcase
        @one_off = find_one_off_by_name(name_downcase)
        flash[:danger] = @one_off.price
        flash[:warning] = @one_off
    end

    private
    def find_one_off_by_name(item)
        # item.gsub!('-', " ")
        OneOffProduct.where(:partner_name.downcase => item)
    end

    def find_plan_type_by_name(item)
        item.gsub!('-', " ")
        PlanType.where(:partner_name.downcase => item)
    end
end