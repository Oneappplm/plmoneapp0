class GroupEngageProviderDecorator < ApplicationDecorator
	def date_of_birth
		object.date_of_birth.strftime("%m/%d/%Y") rescue nil
	end
end
