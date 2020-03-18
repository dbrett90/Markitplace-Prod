class StaticPagesController < ApplicationController
  def home
  end

  def our_team
  end

  def contact
  end

  def contact_test
  end

  def partners
  end

  def partner_contact 
  end

  def create
    UserMailer.contact_support(params[:contact][:contact_name], params[:contact][:contact_email], params[:contact][:contact_how], params[:contact][:contact_help]).deliver_now
    redirect_to contact_url
    flash[:success] = "Your message has been received. We will be in contact shortly."
  end

  def partners_create
    UserMailer.partners_contact_support(params[:partners][:partner_name], params[:partners][:partner_email], params[:partners][:partner_location], params[:partners][:partner_food_type],params[:partners][:partner_post_offering],params[:partners][:partner_analytics],params[:partners][:partner_brand_management]).deliver_now
    redirect_to partner_information_url
    flash[:success] = "Your message has been received. We will be in contact shortly."
  end
end

