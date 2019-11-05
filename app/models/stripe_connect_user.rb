class StripeConnectUser < ApplicationRecord
    validates :stripe_id, presence: true
end
