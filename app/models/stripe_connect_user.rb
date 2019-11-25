class StripeConnectUser < ApplicationRecord
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :stripe_id, presence: true
    validates :stripe_email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }

    #Send the user an email after they have signed up with Stripe
    def send_instructions_email
        StripeSignupMailer.send_instructions(self).deliver_now
    end
end
