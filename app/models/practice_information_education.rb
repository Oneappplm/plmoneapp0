class PracticeInformationEducation < ApplicationRecord
  belongs_to :provider_attest
  has_many :rva_informations, dependent: :destroy
end
