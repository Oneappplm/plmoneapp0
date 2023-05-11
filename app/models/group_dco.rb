class GroupDco < ApplicationRecord
	include PgSearch::Model
  # to jayson country change to county
  attr_accessor :county, :inpatient_facility, :is_clinic, :telehealth_provider
	pg_search_scope :search,
          against: self.column_names,
          using: {
            tsearch: {any_word: true}
          }

	belongs_to :enrollment_group
  has_many :schedules, class_name: 'GroupDcoSchedule', dependent: :destroy
  accepts_nested_attributes_for :schedules, allow_destroy: true, reject_if: :all_blank
end