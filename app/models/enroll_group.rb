class EnrollGroup < ApplicationRecord
	include PgSearch::Model
  include RemovePayorFiles

	pg_search_scope :search,
          against: self.column_names,
          using: {
            tsearch: {any_word: true}
          }

  attr_accessor :enrolled_by, :npi, :ssn

  mount_uploader :voided_bank_letter, DocumentUploader

	belongs_to :group,	class_name: "EnrollmentGroup", foreign_key: "group_id", optional: true

	default_scope { order(:id) }
  scope :completed, -> { where(status: 'completed') }
  scope :pending, -> { where(status: 'pending') }

	has_one :client_provider_enrollment, as: :enrollable, dependent: :destroy
  has_many :details, class_name: 'EnrollGroupsDetail', dependent: :destroy
  has_many :comments, class_name: 'EnrollmentComment', dependent: :destroy
  accepts_nested_attributes_for :details, allow_destroy: true, reject_if: :all_blank

  after_create :create_client_provider_enrollment

	def full_name = "#{first_name}	#{middle_name} #{last_name}"

  def assigned_agent
    User.from_enrollment.find_by(id: self.user_id)
  end

  def create_client_provider_enrollment
    ClientProviderEnrollment.create(enrollable: self)
  end

  def state
    State.find_by(id: self.state_id)
  rescue
    nil
  end
end