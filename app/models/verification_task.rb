class VerificationTask < ApplicationRecord
  belongs_to :provider_profile
  belongs_to :verification_product

  enum status: { pending: 0, verified: 1, failed: 2 }
end
