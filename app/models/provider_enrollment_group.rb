class ProviderEnrollmentGroup < ApplicationRecord
  belongs_to :provider
  serialize :primary_location, Array
  serialize :additional_locations, Array
end
