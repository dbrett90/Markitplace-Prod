class PartnersController < ApplicationController
    def index
        @partners = PartnerLogo.all
        redirect_to partner_logos_path
    end

    def show
        name_downcase = params[:name].downcase
        # flash[:success] = name_downcase
        if name_downcase.include?("-")
            name_downcase = name_downcase.gsub!('-', " ")
        end
        @name = name_downcase
        # flash[:success] = params
        @one_off_products = find_one_off_by_name(name_downcase)
        # flash[:danger] = name_downcase
        # flash[:warning] = @one_offs.length
    end


    private
    #ILIKE is crucial for case-insensitive search
    def find_one_off_by_name(item)
        OneOffProduct.where("partner_name ILIKE ?", item)
    end

    def find_plan_type_by_name(item)
        PlanType.where("partner_name ILIKE ?", item)
    end

    def warning
        flash[:warning] = "These items are currently out of stock"
    end
    helper_method :warning
end