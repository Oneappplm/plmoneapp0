# lib/tasks/create_providers.rake

namespace :db do
	desc "Generate enrollment tracking migrations"
	task create_providers: :environment do
			system "rails generate migration CreateProviders \
					first_name:string \
					middle_name:string \
					last_name:string \
					suffix:string \
					gender:string \
					birth_date:date \
					practitioner_type:string \
					ssn:string \
					npi:string \
					caqhid:string \
					caqh_attestation_date:date \
					caqh_pdf:binary \
					caqh_pdf_date_received:date \
					nccpa_number:string \
					dea_number:string \
					dea_license_effective_date:date \
					dea_license_expiration_date:date \
					dco:boolean \
					dco_file:binary"

			system "rails generate migration CreateProviderTaxonomies \
					provider:references \
					taxonomy_code:string \
					specialty:string"

			system "rails generate migration CreateProviderLicenses \
					provider:references \
					license_number:string \
					license_effective_date:date \
					license_expiration_date:date"

			system "rails generate migration CreateProviderPaLicenses \
					provider:references \
					pa_license_effective_date:date \
					pa_license_expiration_date:date"

			system "rails generate migration CreateProviderNpLicenses \
					provider:references \
					np_license_number:string \
					np_license_effective_date:date \
					np_license_expiration_date:date"

			system "rails generate migration CreateProviderRnLicenses \
					provider:references \
					rn_license_number:string \
					rn_license_effective_date:date \
					rn_license_expiration_date:date"
	end
end
