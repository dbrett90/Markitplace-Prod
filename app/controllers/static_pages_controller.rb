class StaticPagesController < ApplicationController
  def home
  end

  def our_team
  end

  def contact
  end

  def create
    UserMailer.contact_support(params[:contact][:contact_name], params[:contact][:contact_email], params[:contact][:contact_how], params[:contact][:contact_help]).deliver_now
    redirect_to contact_url
  end

end
