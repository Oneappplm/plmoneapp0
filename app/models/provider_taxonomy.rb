class ProviderTaxonomy < ApplicationRecord
  belongs_to :provider
  validates_presence_of :taxonomy_code, :specialty
end
