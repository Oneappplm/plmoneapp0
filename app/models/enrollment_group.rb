class EnrollmentGroup < ApplicationRecord
  has_many :dcos, class_name: 'GroupDco', dependent: :destroy

  validates_presence_of :group_name, :group_code, :office_address, :city, :state, :zip_code, :phone_number, :fax_number

  def dco_count_display
    "#{dcos.size} #{group_code} clients"
  end
end