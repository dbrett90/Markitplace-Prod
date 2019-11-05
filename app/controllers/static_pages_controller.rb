class StaticPagesController < ApplicationController
  def home
    Stripe.api_key = Rails.application.credentials.development[:stripe_api_key]
    auth_code = params[:code]
    stripe_callback(stripe.api_key, auth_code)
  end

  def our_team
  end

  def contact
  end

  def partners
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

private

def stripe_callback(api_key, code)
  #Attempting to retrieve customer info from stripe after they connect
  #Note that we're also going to store plan_id in in credentials folder
  Stripe.api_key = Rails.application.credentials.development[:stripe_api_key]
  response = Stripe::OAuth.token({
    grant_type: 'authorization_code',
    code: code
  })
  connected_account_id = response.stripe_user_id
  flash[:success] = connected_account_id
end