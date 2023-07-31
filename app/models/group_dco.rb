class GroupDco < ApplicationRecord
	include PgSearch::Model
	pg_search_scope :search,
          against: self.column_names,
          using: {
            tsearch: {any_word: true}
          }

	belongs_to :enrollment_group
  has_many :schedules, class_name: 'GroupDcoSchedule', dependent: :destroy
  has_many :provider_outreach_info, class_name: 'GroupDcoProviderOutreachInformation', dependent: :destroy
  has_many :notes, class_name: 'GroupDcoNote', dependent: :destroy
  has_many :old_location_addresses, class_name: 'GroupDcoOldLocationAddress', dependent: :destroy

  # validate :number_of_schedules
  # validate :number_of_provider_outreach_info

  accepts_nested_attributes_for :schedules, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :provider_outreach_info, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :old_location_addresses, allow_destroy: true, reject_if: :all_blank

  def number_of_schedules
    errors.add(:base, "Should have at least one schedule") if schedules.length == 0 && Setting.take.qualifacts?
  end

  def number_of_provider_outreach_info
    errors.add(:base, "Should have at least one service contact") if provider_outreach_info.length == 0 && Setting.take.qualifacts?
  end
end