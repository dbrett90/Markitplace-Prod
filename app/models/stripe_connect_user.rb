class StripeConnectUser < ApplicationRecord
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :stripe_id, presence: true
    validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }
end
