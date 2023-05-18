class EnrollGroup < ApplicationRecord
	include PgSearch::Model
	pg_search_scope :search,
          against: self.column_names,
          using: {
            tsearch: {any_word: true}
          }

	belongs_to :group,	class_name: "EnrollmentGroup", foreign_key: "group_id", optional: true
  validates_presence_of :first_name, :middle_name, :last_name, :telephone_number

	default_scope { order(:id) }

  has_many :details, class_name: 'EnrollGroupsDetail'
  accepts_nested_attributes_for :details, allow_destroy: true, reject_if: :all_blank


	def full_name = "#{first_name}	#{middle_name} #{last_name}"
end