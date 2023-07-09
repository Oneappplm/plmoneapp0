class GroupDcoContact < ApplicationRecord
  belongs_to :group_dco

  validates_presence_of :department, :name, :role, :phone, :email
end
