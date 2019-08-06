class StaticPagesController < ApplicationController
  def home
  end

  def our_team
  end

  def contact
    user_email = params[:contact_email]
    user_name = params[:contact_name]
    user_how = params[:optional-info-1]
    user_msg = params[:optional-info-2]
    UserMailer.contact_support(user_name, user_email, user_how, user_msg).deliver_now
  end
end
