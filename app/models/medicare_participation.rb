class MedicareParticipation < ApplicationRecord

    belongs_to :provider_attest, optional: true
    validates :provider_attest_id, presence: true
		belongs_to :provider_personal_information,
							primary_key: :provider_attest_id,
							foreign_key: :provider_attest_id,
							optional: true
end
