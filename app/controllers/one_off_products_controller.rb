class OneOffProductsController < ApplicationController
    #May need to add library type to before action for set_product
    before_action :set_product_type, only: [:edit, :show, :update, :destroy]
    before_action :logged_in?, except: [:index, :show]

    def index
        #Show all the one-offs
        @one_off_products = OneOffProduct.all
    end

    def new
        @one_off_product = current_user.one_off_products.build
    end
    
    def show
    end

    def edit
    end

    #This is where we'll link to stripe to create the one-off-product
    def create
        #Going to create the plan on behalf of the client - need key
        Stripe.api_key = Rails.application.credentials.development[:stripe_api_key]
        @one_off_product = current_user.one_off_products.build(one_off_product_params)
        #Create a new product and a new SKU
        stripe_product = Stripe::Product.create({
            #Might need to include a pricing input value here so it's dynamic and not hard-coded.
            #Also need to figure out what the billing period for this would be.
            name: @one_off_product.name,
            description: @one_off_product.description,
            # amount_decimal: (@plan_type.price * 100),
            # currency: 'usd'
          },
          {stripe_account: @one_off_product.stripe_id})

          stripe_sku = Stripe::SKU.create({
              price: (@one_off_product.price * 100),
              currency: 'usd',
              inventory: {type: 'infinite'},
              product: stripe_product.id,
            },
            {stripe_account: @one_off_product.stripe_id})

        respond_to do |format|
            if @one_off_product.save
                flash[:success] = params
                format.html { redirect_to plan_types_path, success: 'ONE OFF PRODUCT was successfully created.' }
                format.json { render :index, status: :created, location: @one_off_product }
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
    end

    def destroy
    end

    private

    def set_product_type
        @one_off_product = OneOffProduct.find(params[:id])
    end

    def one_off_product_params
        params.require(:one_off_product).permit(:name, :description, :product_id, :price, :partner_name, :user_id, :created_at, :updated_at, :stripe_id, :thumbnail)
    end
end