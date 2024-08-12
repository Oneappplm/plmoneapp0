class ClientOrganization < ApplicationRecord
	# def address = "#{address1} #{address2}"
	has_many :practitioners
end