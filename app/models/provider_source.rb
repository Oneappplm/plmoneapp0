class ProviderSource < ApplicationRecord
	has_many :data, class_name: 'ProviderSourceData',	inverse_of: :provider_source, dependent: :destroy
	scope :current, ->{ find_by(current_provider_source: true) }
end