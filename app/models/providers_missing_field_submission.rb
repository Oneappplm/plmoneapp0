class ProvidersMissingFieldSubmission < ApplicationRecord
  belongs_to :provider

  scope :pending, -> { where(status: 'pending') }

  has_many :data, class_name: 'ProvidersMissingFieldSubmissionsData', dependent: :destroy

  def create_missing_field_submission_data(key, value, attribute = nil)
    ProvidersMissingFieldSubmissionsData.find_or_create_by(providers_missing_field_submission_id: self.id,data_key: key, data_value: value, data_attribute: attribute)
  end

  def update_provider_fields
    provider = Provider.find(self.provider_id)
    if data
      data.each do |field|
        if field.data_attribute.nil?
          provider.update_attribute(field.data_key, field.data_value)
        else
          if field.data_attribute == 'licenses_attributes'
            license = ProviderLicense.find_by(provider_id: provider.id)
            license.update_attribute(field.data_key, field.data_value.to_i)
          end
        end
      end
    end
  rescue
    false
  end

end