class ProviderMedicaid < ApplicationRecord
  belongs_to :provider, optional: true
end