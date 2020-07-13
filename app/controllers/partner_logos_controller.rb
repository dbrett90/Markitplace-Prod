class PartnerLogosController < ApplicationController
    before_action :set_logo, only: [:show, :edit, :update, :destroy]
    before_action :admin_user, except: [:index, :playbook, :download_playbook]

    def index
        @partner_logos = PartnerLogo.all 
    end

    #Do we want a show here? Not sure about this really. Index may be enough
    def show 
    end

    def new 
        @partner_logo = PartnerLogo.new 
    end

    def create
        @parner_logo = PartnerLogo.new(partner_logo_params)
        if @parner_logo.save
            redirect_to partner_logos_path
        else
            render 'new'
        end
    end

     #Form should probably stay the same when you upload a new logo
     #Confirm that you can find by the ID in this instance
    def edit
        @partner_logo = PartnerLogo.find(params[:id])
    end

    def update
        @partner_logo = PartnerLogo.find(params[:id])
        if @partner_logo.update_attributes(partner_logo_params)
            flash[:success] = "The partner logo & info has been updated successfully"
            redirect_to partner_logos_path
        else
            render 'edit'
        end
    end

    def destroy
        PartnerLogo.find(params[:id]).destroy
        # flash[:warning] = params
        flash[:success] = "Partner Logo Deleted"
        redirect_to partner_logos_path
    end

    def playbook 
    end

    def download_playbook
        #Save users credentials to the database
        @playbook_user = PlaybookUser.new()
        @playbook_user.name = params[:playbook][:name]
        @playbook_user.email = params[:playbook][:email]
        @playbook_user.phone_number = params[:playbook][:phone_number]
        @playbook_user.save  
        #Download File & redirect. Flash notice that download complete./home/daniel/markitplace-prod/app/assets/images/Markitplace_Meal_Kit_Playbook.pdf
        send_file "#{Rails.root}/app/assets/images/markitplace_meal_kit_playbook.pdf", type: "application/pdf", x_sendfile: true
        redirect_to mealkit_playbook_path
        flash[:success] = "Please check your downloads folder for the playbook."
        flash[:warning] = "test"
    end

    private

    def set_logo
        @parnter_logo = PartnerLogo.find(params[:id])
    end

    def partner_logo_params
        params.require(:partner_logo).permit(:name, :description, :dedicated_link, :created_at, :updated_at, :thumbnail)
    end

    def admin_user
        redirect_to(root_url) unless current_user.admin?
    end

    def warning
        flash.now[:warning] = "Kits from this partner are no longer available"
    end
    helper_method :warning

end