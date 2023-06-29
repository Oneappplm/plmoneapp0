class EnrollmentGroup < ApplicationRecord
  mount_uploader :w9_file, DocumentUploader
  mount_uploader :cp575_file, DocumentUploader
  mount_uploader :specific_type_file, DocumentUploader
  mount_uploader :ownership_file, DocumentUploader
  mount_uploader :payer_contracts, DocumentUploader
  mount_uploader :group_type_documents, DocumentUploader
  mount_uploader :eft_file, DocumentUploader
  mount_uploader :voided_check_file, DocumentUploader


  has_many :dcos, class_name: 'GroupDco', dependent: :destroy
  has_many :details, class_name: 'EnrollmentGroupsDetail'
  has_many :contact_personnels, class_name: 'EnrollmentGroupsContactDetail'

  accepts_nested_attributes_for :contact_personnels, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :details, allow_destroy: true, reject_if: :all_blank

  validates_presence_of :group_name, :group_code, :office_address, :city, :state, :zip_code, :phone_number, :fax_number

  def dco_count_display
    "#{dcos.size} #{group_code} clients"
  end

  def selected_provider_types
     self.provider_type ? self.provider_type.split(',') : nil
  end
end