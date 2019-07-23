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
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "You've successfully registered your account!"
      redirect_to @user
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
