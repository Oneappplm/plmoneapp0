class ProviderSource < ApplicationRecord
	has_many :data, class_name: 'ProviderSourceData',	inverse_of: :provider_source, dependent: :destroy
	has_many	:documents, class_name: 'ProviderSourceDocument', inverse_of: :provider_source, dependent: :destroy
	scope :current, ->{ find_by(current_provider_source: true) }
	default_scope {	order(current_provider_source: :desc) }
	def fetch(key = nil)
		data.find_by(data_key: key)&.data_value
	end

	def full_name
	 "#{fetch('first_name')} #{fetch('last_name')}"
	end

	def states
		"#{fetch('states')}"
	end

	def current_provider_source?
	 current_provider_source ? 'Yes' : 'No'
	end

	def self.test_document_upload
		provider_source = ProviderSource.current
		document = provider_source.documents.new
		document.file_path = File.open(File.join(Rails.root, 'lib', 'data', 'languages.csv'))
		document.file_name = 'languages.csv'
		document.save
		document.file_path.url
	end
end