class PlanTypesController < ApplicationController
    #Updated to allow users to access a library
 before_action :set_plan_type, only: [:edit, :show, :update, :destroy, :library]
 before_action :admin_user, only: [:new, :edit, :create, :update, :destroy]
# before_action :authenticate_user!, except: [:index, :show]
#This is what the Devise action basically does.
#before_action :logged_in_user, except: [:index, :show]

#  def plans 
#  end
 # GET /plans
 def index
   @plan_types = PlanType.all
 end

 # GET /plans/1
 # GET /plans/1.json
 # GET /plans/new
 def new
    #What is te current_user equivalent? See if this works
    # @plan_types = PlanType.all
    @plan_type = PlanType.new 
    @plan_types = PlanType.all
 end

 def show
    Stripe.api_key = Rails.application.credentials.production[:stripe_api_key]
    token = params[:stripeToken]
    @plan_type = PlanType.find(params[:id])
    sub_name = @plan_type.name
    if logged_in?
        #Generate a session for the user
        #determine if promo_code applied & create session
        #Create session either with promo or without
        session_id = request.session_options[:id]
        stripe_session = Stripe::Checkout::Session.create(
            customer_email: current_user.email,
            payment_method_types: ['card'],
            shipping_address_collection: {
                        allowed_countries: ['US'],
            },
            line_items: [{
                price: @plan_type.stripe_id,
                quantity: 1,
            }],
            allow_promotion_codes: true,
            mode: 'subscription',
            success_url: "http://www.markitplace.io/successful-subscription-purchase?session_id=#{session_id}",
            cancel_url: 'http://www.markitplace.io/unsuccessful-subscription-purchase',
        )
        # @session = stripe_session
        # #To be referenced afterwards
        # session[:stripe_id] = @session.id
        #Temporary way to retrieve the stripe_id of a subscription
        # current_user.subscription_session_id[@plan_type.id] = stripe_session.id
        # current_user.save
        #session[:cocktail_subscription_id] = @plan_type.id
    else
        #session[:signup_redirect_url] = request.original_url
        session_id = request.session_options[:id]
        stripe_session = Stripe::Checkout::Session.create(
            payment_method_types: ['card'],
            shipping_address_collection: {
                        allowed_countries: ['US'],
            },
            line_items: [{
                price: @plan_type.stripe_id,
                quantity: 1,
            }],
            allow_promotion_codes: true,
            mode: 'subscription',
            success_url: "http://www.markitplace.io/successful-subscription-purchase?session_id=#{session_id}",
            cancel_url: 'http://www.markitplace.io/unsuccessful-subscription-purchase',
        )
        # @session = stripe_session
        # #To be referenced afterwards
        # session[:stripe_id] = @session.id
    end
    @session = stripe_session
    session[:stripe_id] = @session.id
    session[:cocktail_subscription_id] = @plan_type.id
 end


 # GET /plans/1/edit
def edit
  @plan_type = PlanType.find(params[:id]) 
end

 # POST /plans
 # POST /plans.json
#Essentially trying to replicate devise here.
#Let's confirm that this actually pulls the current user. 
def create
  @plan_type = PlanType.new(plan_type_params)
  if @plan_type.save
      flash[:success] = "Plan Type Offering has been successfully added!"
      redirect_to plan_types_path
  else
      render 'new'
  end
end

 # PATCH/PUT /books/1
 # PATCH/PUT /books/1.json
 #Not abiding by DRY here.... essetially call the Create part? 
 def update
  @plan_type = PlanType.find(params[:id])
  if @plan_type.update_attributes(plan_type_params)
      flash[:success] = "Plan Type hass been updated"
      redirect_to @plan_type
  else
      render 'edit'
  end
end

 # DELETE /books/1
 # DELETE /books/1.json
def destroy
  PlanType.find(params[:id]).destroy
  flash[:success] = "Plan Type Deleted"
  redirect_to plan_types_path
end

 #Add and remove plans from Library for the current user
 def library
    # current_user = User.find(params[:id])
    type = params[:type]
    if type=="add"
        #Add the plan to the library additions array - need to change this
        current_user.plan_subscription_library_additions << @plan_type
        redirect_to plan_subscription_library_index_path, notice: "#{@plan_type.name} was added to your active subscriptions!"
    elsif type=="remove"
        current_user.plan_subscription_library_additions.delete(@plan_type)
        redirect_to root_path, notice: "#{@plan_type.name} was removed from your active subscriptions. you will no longer be charged"
    else
        #type is missing, nothing should happen
        redirect_to plan_type_path(@plan_type), notice: "Looks like something went wrong! Use the contact form if this continues to cause issues."
    end
 end

 def successful_subscription_purchase
  plan_type_subscription = find_plan_type_subscription_by_id(session[:plan_type_id])
  current_user.plan_types << plan_type_subscription
  current_user.save
  # OrderConfirmationMailer.subscription_order.deliver_now
  flash[:success] = "Your subscription is now active! You will receive a confirmation email shortly."
  redirect_to root_path
end

def unsuccessful_subscription_purchase
  flash[:danger] = "Your checkout session didn't complete. Please try again."
  redirect_to plan_types_path
end

 private
   # Use callbacks to share common setup or constraints between actions.
   #Grab the current plan_type
   def set_plan_type
    @plan_type = PlanType.find(params[:id])
   end

   def parse_extended_field(plan_type)
    extended_field = plan_type.extended_description
    extended_list = extended_field.split(',')
    return extended_list
   end

  def strip_spaces(keyword)
    return keyword.gsub!(/\s/,'_')
  end

   # Never trust parameters from the scary internet, only allow the white list through.
    #Update with User ID?
   def plan_type_params
     params.require(:plan_type).permit(:name, :description, :extended_description, :city_delivery, :created_at, :updated_at, :stripe_id, :price, :is_trial, :calories, :protein, :fats, :servings, :prep_time, :thumbnail)
   end

   def admin_user
    redirect_to(root_path) unless current_user.admin?
   end
end

