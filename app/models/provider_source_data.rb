class ProviderSourceData < ApplicationRecord
	belongs_to :provider_source, inverse_of: :data, optional: true
	scope :find_key, ->(key = nil){ find_by(data_key: key) }
	scope :find_value, ->(key = nil){ find_key(key)&.data_value }

	def active_class = (data_value == 'yes' ? 'active' : '')
	def hide_class = (data_value == 'no' ? 'd-none' : '')
end