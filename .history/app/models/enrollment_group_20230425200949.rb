class Enrollment_Group < ApplicationRecord

  validates_presence_of :name, :email, :phone, :fax, :address, :city, :state, :zip, :status
  
  
  
  def enrollment_group_name = "#{name}"
end