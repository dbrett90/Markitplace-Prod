class OneOffProductsController < ApplicationController
    #May need to add library type to before action for set_product
    before_action :set_product_type, only: [:edit, :show, :update, :destroy]
    before_action :admin_user, except: [:index, :show, :test_item]

    def index
        #Show all the one-offs
        @one_off_products = OneOffProduct.order(:sort_priority, :out_of_stock)
    end

    #Actions and methods for testing items
    def test_item
        @one_off_product = OneOffProduct.find(19)
        # flash[:danger] = params
    end

    def test_index
        @one_off_products = OneOffProduct.order(:out_of_stock)
        @partners = PartnerLogo.all
    end
    #Regular methods again
    def new
        @one_off_product = current_user.one_off_products.build
    end
    
    def show
    end

    def edit
    end

    #This is where we'll link to stripe to create the one-off-product
    #SKU only letting us set a certain amount... need to think about this
    def create
        #Going to create the plan on behalf of the client - need key
        Stripe.api_key = Rails.application.credentials.production[:stripe_api_key]
        @one_off_product = current_user.one_off_products.build(one_off_product_params)
        #Create a new product and a new SKU
        stripe_product = Stripe::Product.create({
            #Might need to include a pricing input value here so it's dynamic and not hard-coded.
            #Also need to figure out what the billing period for this would be.
            name: @one_off_product.name,
            description: @one_off_product.description,
            type: "good",
            # amount_decimal: (@plan_type.price * 100),
            # currency: 'usd'
          },
          {stripe_account: @one_off_product.stripe_id})
          @one_off_product.update_attribute(:product_id, stripe_product.id)

        respond_to do |format|
            if @one_off_product.save
                flash[:success] = params
                format.html { redirect_to @one_off_product, success: 'ONE OFF PRODUCT was successfully created.' }
                format.json { render :show, status: :created, location: @one_off_product }
                flash[:warning] = "Make sure you update the credentials file with product ID"
               # @plan_type.plan_type_id = stripe_plan.id
               # @plan_type.save
            else
                flash[:danger] = "SOME TYPE OF ISSUE WITH CREATION"
                flash[:notice] = @one_off_product.errors.full_messages
                format.html { render :new }
                format.json { render json: @one_off_product.errors, status: :unprocessable_entity }
            end
        end
    end

    def update
        #Going to create the plan on behalf of the client - need key
        Stripe.api_key = Rails.application.credentials.production[:stripe_api_key]
        #@one_off_product = current_user.one_off_products.build(one_off_product_params)
        #Create a new product and a new SKU

        respond_to do |format|
            if @one_off_product.update(one_off_product_params)
                flash[:success] = params
                format.html { redirect_to @one_off_product, success: 'ONE OFF PRODUCT was successfully created.' }
                format.json { render :show, status: :created, location: @one_off_product }
                flash[:warning] = "Make sure you update the credentials file with product ID"
               # @plan_type.plan_type_id = stripe_plan.id
               # @plan_type.save
            else
                flash[:danger] = "SOME TYPE OF ISSUE WITH CREATION"
                flash[:notice] = @one_off_product.errors.full_messages
                format.html { render :new }
                format.json { render json: @one_off_product.errors, status: :unprocessable_entity }
            end
        end
        stripe_product = Stripe::Product.create({
            #Might need to include a pricing input value here so it's dynamic and not hard-coded.
            #Also need to figure out what the billing period for this would be.
            name: @one_off_product.name,
            description: @one_off_product.description,
            type: "good",
          },
          {stripe_account: @one_off_product.stripe_id})
          @one_off_product.update_attribute(:product_id, stripe_product.id)
    end

    #Need to buil in a way to destroy the product at some point
    def destroy
        @one_off_product.destroy
        respond_to do |format|
            format.html { redirect_to one_off_products_path, success: 'Product was successfully deleted.' }
            format.json { head :no_content }
        end
    end


    private

    def set_product_type
        @one_off_product = OneOffProduct.find(params[:id])
    end

    def one_off_product_params
        params.require(:one_off_product).permit(:name, :description, :extended_description, :available_cities, :delivery_schedule, :product_id, :price, :partner_name, :partner_background_link, :user_id, :calories, :fats, :servings, :prep_time, :created_at, :updated_at, :stripe_id, :is_trial, :out_of_stock, :flavor_options, :thumbnail)
    end

    #This is not DRY. Pulling from users controller
    def admin_user
        redirect_to(root_path) unless current_user.admin?
    end

    def generate_flavor_options_list(flavor_options)
        flavor_options.split(",")
    end
    helper_method :generate_flavor_options_list
end