class PartnerInformation < ApplicationRecord
    #Just saying that each of these constructs have a thumbnail attached
    has_one_attached :thumbnail
end