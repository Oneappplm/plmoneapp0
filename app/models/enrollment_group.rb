class EnrollmentGroup < ApplicationRecord
  mount_uploader :w9_file, DocumentUploader
  mount_uploader :cp575_file, DocumentUploader
  mount_uploader :specific_type_file, DocumentUploader
  mount_uploader :ownership_file, DocumentUploader

  has_many :dcos, class_name: 'GroupDco', dependent: :destroy

  validates_presence_of :group_name, :group_code, :office_address, :city, :state, :zip_code, :phone_number, :fax_number

  def dco_count_display
    "#{dcos.size} #{group_code} clients"
  end

  def selected_provider_types
     self.provider_type ? self.provider_type.split(',').map{|m| m.to_i} : nil
  end
end