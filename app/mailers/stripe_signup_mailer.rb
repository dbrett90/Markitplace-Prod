class StripeSignupMailer < ApplicationMailer

    #Initial instructions for an account that has been linked
    def send_instructions(stripe_user)
        @stripe_connect_user = stripe_user
        mail to: stripe_user.stripe_email, cc: "danbrett107@gmail.com", subject: "Markitplace Account Linked"
    end
end

