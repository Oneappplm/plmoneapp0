class GroupDcoProviderOutreachInformation < ApplicationRecord
	belongs_to :group_dco
	validates_presence_of	:name, :email, :phone, :fax, :position
end