class ClientOrganization < ApplicationRecord
	def address = "#{address1} #{address2}"

	ORGANIZATION_TYPE = [
 		"Allied Health Network",
 		"Clinic",
 		"Durable Medical Equipment Provider",
 		"Health Maintenance Organization",
 		"Health Plan",
 		"Health System",
 		"Hospital",
 		"Medical Group",
 		"Pharmacy",
 		"Preferred Provider Network",
 		"Public Health Service",
 		"Surgery Center"
 	]
end