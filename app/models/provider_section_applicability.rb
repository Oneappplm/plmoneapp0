class ProviderSectionApplicability < ApplicationRecord
  belongs_to :provider_personal_information

  validates :section_key, presence: true

  validates :section_key,
            uniqueness: {
              scope: :provider_personal_information_id
            }

  validates :explanation,
            presence: true,
            if: :not_applicable?
end