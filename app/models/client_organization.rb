class ClientOrganization < ApplicationRecord
	def address = "#{address1} #{address2}"
end