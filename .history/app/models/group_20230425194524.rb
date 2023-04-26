class Group < ApplicationRecord

  validates_presence_of :name, :email, :phone, :fax, :address, :city, :state, :zip, :status

  def provider_name = "#{first_name} #{middle_name} #{last_name}"
  def provider_degree = nil
end