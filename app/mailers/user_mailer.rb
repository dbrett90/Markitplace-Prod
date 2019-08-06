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
    mail to: "danbrett107@gmail.com", subject: "Markitplace Support Required", from: user_email
  end
end
