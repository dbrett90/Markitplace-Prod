class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :destory]
  before_action :correct_user,   only: [:edit, :update]
  #Only admin has capability to destroy users
  before_action :admin_user,     only: :destroy

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    redirect_to root_url and return unless @user.activated?
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      #UserMailer.account_activation(@user).deliver_now
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Your Profile has been updated successfully"
      redirect_to @user
    else
      # May need to change this to render 'edit'
      render 'edit'
    end
  end

  #This is for the admin to destroy users - may need to change this at some point though. 
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User Account Deleted"
    redirect_to users_url
  end

  #This is to determine the type of user when first creating
  def business_or_customer
  end

  def business_or_customer_create
    select_output = params[:business_or_customer][:business_or_customer_select]
    #Make sure the "Purchase Meal Kits" is not changed in the view as it will
    #affect the output of this controller. Binary Value
    if select_output == "Purchase Meal Kits"
      redirect_to signup_url
      # For some reason the stripe.api_key is not going through. Need to debug
      # flash[:success] = Stripe.api_key
    else
      redirect_to "https://connect.stripe.com/oauth/authorize?response_type=code&client_id=ca_FX0EKPNDzWlcxcjjUNnxNAhUa0cjuVBI&scope=read_write"
    end
  end

  def grab_stripe_details
    Stripe.api_key = Rails.application.credentials.development[:stripe_api_key]
    auth_code = params[:code]
    response = Stripe::OAuth.token({
      grant_type: 'authorization_code',
      code: auth_code
    })
    connected_account_id = response.stripe_user_id
    flash[:success] = connected_account_id
    flash[:danger] = auth_code
    render 'static_pages/home'
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please Log In"
      redirect_to login_url
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end
