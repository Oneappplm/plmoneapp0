# lib/tasks/create_providers.rake

namespace :data do
	desc "Generate ClientProviderEnrollment for all existing EnrollGroup and EnrollmentProvider"
	task create_client_provider_enrollments: :environment do
		EnrollGroup.includes(:client_provider_enrollment).where(client_provider_enrollments: { id: nil}).each do |eg|
			ClientProviderEnrollment.create(enrollable: eg)
		end
		EnrollmentProvider.includes(:client_provider_enrollment).where(client_provider_enrollments: { id: nil}).each do |eg|
			ClientProviderEnrollment.create(enrollable: eg)
		end
	end
end
