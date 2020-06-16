class PartnersController < ApplicationController
    def index
        @partners = PartnerLogo.all
        redirect_to partner_logos_path
    end

    def show
        name_downcase = params[:name].downcase
        # flash[:success] = name_downcase
        @name = params[:name]
        @one_off_products = find_one_off_by_name(name_downcase)
        #flash[:danger] = @one_off.price
        # flash[:warning] = @one_offs.length
    end

    private
    def find_one_off_by_name(item)
        item.gsub!('-', " ")
        OneOffProduct.where("partner_name ILIKE ?", item)
    end

    def find_plan_type_by_name(item)
        item.gsub!('-', " ")
        PlanType.where("partner_name ILIKE ?", item)
    end
end