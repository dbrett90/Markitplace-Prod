class PartnerInformationController < ApplicationController
    before_action :set_partner_info, only: [:show, :edit, :update, :destroy]
    before_action :admin_user, except: [:show]

    #Need all these REST methods? Doubtful
    def index
        @partner_information = PartnerInformation.all
    end

    def new
        @partner_information = PartnerInformation.new
    end

    def create
        @partner_information = PartnerInformation.new(partner_information_params)
        if @partner_information.save
            redirect_to root_path
        else
            render 'new'
        end
    end

    def edit
        @partner_information = PartnerInformation.find(params[:id])
    end

    def update
        @partner_information = PartnerInformaton.find(params[:id])
        if @partner_information.update_attributes(partner_information_params)
            flash[:success] = "The partner Info page has been updated"
            redirect_to root_path
        else
            render 'edit'
        end
    end
    
    def destroy
        PartnerInformation.find(params[:id]).destroy
        # flash[:warning] = params
        flash[:success] = "Partner Logo Deleted"
        redirect_to root_path
    end

    private

    def set_partner_info
        @parnter_logo = PartnerInformation.find(params[:id])
    end

    def partner_information_params
        params.require(:partner_information).permit(:name, :tag_line, :description, :created_at, :updated_at, :thumbnail)
    end

    def admin_user
        redirect_to(root_url) unless current_user.admin?
    end
end
