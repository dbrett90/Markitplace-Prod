class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #
  def account_activation(user)
    @user = user
    mail to: user.email, subject: "Markitplace Account Activation"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Markitplace Account Password Reset"
  end

  #This is specifically for contacting support
  def contact_support(user_name, user_email, user_how, user_msg)
    @user_name = user_name
    @user_how = user_how 
    @user_msg = user_msg
    mail to: "danbrett107@gmail.com", cc:"harrington.robert15@gmail.com", subject: "Markitplace Support Required", from: user_email
  end

  def partners_contact_support(partner_name, partner_email, partner_location, partner_cuisine, partner_post_offerings, partner_analytics_reports, partner_brand_management )
    @partner_name=partner_name
    @partner_email=partner_email
    @partner_location=partner_location
    @partner_cuisine=partner_cuisine 
    @partner_post_offerings=partner_post_offerings
    @partner_analytics_reports=partner_analytics_reports
    @partner_brand_management=partner_brand_management
    mail to: "danbrett107@gmail.com", cc:"harrington.robert15@gmail.com",  subject: "PARTNER INTEREST REQUEST", from: partner_email
  end
end
