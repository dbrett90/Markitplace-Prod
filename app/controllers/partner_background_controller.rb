class PartnerBackgroundController < ApplicationController
    before_action :set_partner_info, only: [:show, :edit, :update, :destroy]
    before_action :admin_user, except: [:show]

    #Need all these REST methods? Doubtful
    def index
        @partner_backgrounds = PartnerBackground.all
    end

    def new
        @partner_background = Partnerbackground.new
    end

    def create
        @partner_background = Partnerbackground.new(partner_background_params)
        if @partner_background.save
            redirect_to root_path
        else
            render 'new'
        end
    end

    def edit
        @partner_background = Partnerbackground.find(params[:id])
    end

    def update
        @partner_background = PartnerInformaton.find(params[:id])
        if @partner_background.update_attributes(partner_background_params)
            flash[:success] = "The partner Info page has been updated"
            redirect_to root_path
        else
            render 'edit'
        end
    end
    
    def destroy
        Partnerbackground.find(params[:id]).destroy
        # flash[:warning] = params
        flash[:success] = "Partner Logo Deleted"
        redirect_to root_path
    end

    private

    def set_partner_info
        @parnter_background = Partnerbackground.find(params[:id])
    end

    def partner_background_params
        params.require(:partner_background).permit(:name, :tag_line, :description, :created_at, :updated_at, :thumbnail)
    end

    def admin_user
        redirect_to(root_url) unless current_user.admin?
    end
end
