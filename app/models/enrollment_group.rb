class EnrollmentGroup < ApplicationRecord
  mount_uploader :ownership_file, DocumentUploader
  mount_uploader :w9_file, DocumentUploader
  mount_uploader :cp575_file, DocumentUploader
  mount_uploader :payer_contracts, DocumentUploader
  mount_uploader :group_type_documents, DocumentUploader
  mount_uploader :eft_file, DocumentUploader
  mount_uploader :voided_check_file, DocumentUploader
  mount_uploader :specific_type_file, DocumentUploader

  has_many :details, class_name: 'EnrollmentGroupsDetail'
  has_many :dcos, class_name: 'GroupDco', dependent: :destroy
  has_many :providers, class_name: 'Provider', dependent: :destroy
  has_many :contact_personnels, class_name: 'EnrollmentGroupsContactDetail'
  has_many :qualifacts_contacts, class_name: 'GroupContact', dependent: :destroy
  has_one :enroll_group, class_name: 'EnrollGroup', foreign_key: "group_id", dependent: :destroy
  has_many :deleted_document_logs, class_name: 'EnrollmentGroupDeletedDocLog', dependent: :destroy
  has_many :users_enrollment_groups
  has_many :users, through: :users_enrollment_groups

  accepts_nested_attributes_for :details, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :qualifacts_contacts, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :contact_personnels, allow_destroy: true, reject_if: :all_blank

  # validates_presence_of :group_name, :group_code, :office_address, :city, :state, :zip_code

  default_scope { order(:group_name) }

  def dco_count_display
    "#{dcos.size} Location(s)"
  end

  def selected_provider_types
     self.provider_type ? self.provider_type.split(',') : nil
  end

  def upload_documents
    [ ['ownership_file', 'Multiple Ownership'],
      ['w9_file', 'W9 Form'],
      ['cp575_file', 'CP575 or Proof of TIN'],
      ['payer_contracts', 'Qualifacts Documents'],
      ['group_type_documents', 'Other Group Documents'],
      ['voided_check_file', 'Voided Check'],
      ['specific_type_file', 'Articles of Incorporation'],
      ['eft_file', 'Liability Insurance']
    ]
  end
end