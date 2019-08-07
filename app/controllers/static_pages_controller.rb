class StaticPagesController < ApplicationController
  def home
  end

  def our_team
  end

  def contact
  end

  def create
    UserMailer.contact_support(params[:contact_name], params[:contact_email], params[:contact_how], params[:contact_help]).deliver_now
    redirect_to contact_url
  end

end
