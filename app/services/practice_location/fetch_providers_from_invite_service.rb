class PracticeLocation::FetchProvidersFromInviteService < BaseService
	attr_reader :providers_invite_completed_under_practice_location, :providers_invite_completed_not_under_practice_location

	def initialize(practice_location)
		@providers_invite_completed_under_practice_location = practice_location.group_engage_providers.map{|gep| gep.user if gep.user && gep.user.invite_completed?}.compact
		@providers_invite_completed_not_under_practice_location = GroupEngageProvider.where.not(practice_location_id: practice_location.id).map{|gep| gep.user if gep.user && gep.user.invite_completed?}.compact
	end

	def filtered_response
		{
			providers_invite_completed_under_practice_location: providers_invite_completed_under_practice_location,
			providers_invite_completed_not_under_practice_location: providers_invite_completed_not_under_practice_location,
		}
	end
end
