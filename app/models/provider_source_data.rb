class ProviderSourceData < ApplicationRecord
	belongs_to :provider_source, inverse_of: :data, optional: true
	scope :find_key, ->(key = nil){ find_by(data_key: key) }
	scope :find_value, ->(key = nil){ find_key(key)&.data_value }
end