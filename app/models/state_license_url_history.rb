class StateLicenseUrlHistory < ApplicationRecord
  belongs_to :state

  default_scope { order(changed_at: :desc) }
end
