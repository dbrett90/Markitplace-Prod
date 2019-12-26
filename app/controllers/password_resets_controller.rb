class PasswordResetsController < ApplicationController
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]    # Case (1) - an expired password reset

  def new
  end

  def edit
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email with password reset instructions sent"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def update
    if params[:user][:password].empty?                  # Case (3) - A failed update (which initially looks “successful”) due to an empty password and confirmation. Make sure program catches this
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    elsif @user.update_attributes(user_params)          # Case (4) - a Successful Update
      log_in @user
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Password has been reset."
      #Changing this line
      #redirect_to @user
      redirect_to root_url
    else
      render 'edit'                                     # Case (2) - Failed Update due to invalid Password. NOTE: MUST UPDATE THE REGEX FOR THIS FOR MORE STRINGENT PASSWORD REQUIREMENTS
    end
  end

  private
  #Specify what parameters are allowed
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  #Find the appropriate User
  def get_user
    @user = User.find_by(email: params[:email])
  end

  # Confirms a valid user.
  def valid_user
    unless (@user && @user.activated? &&
            @user.authenticated?(:reset, params[:id]))
      redirect_to root_url
    end
  end

    # Checks expiration of reset token.
  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "Password reset has expired."
      redirect_to new_password_reset_url
    end
  end
end
