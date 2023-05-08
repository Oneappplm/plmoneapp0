# lib/tasks/generate/providers_models.rake

namespace :generate do
	desc "Generate enrollment tracking models with nested attributes"
	task providers_models: :environment do
			system "rails generate model Provider \
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
					dco_file:binary \
					taxonomies_attributes:references{polymorphic} \
					licenses_attributes:references{polymorphic} \
					--skip-migration"

			system "rails generate model ProviderTaxonomy \
					taxonomy_code:string \
					specialty:string \
					provider:references{polymorphic} \
					--skip-migration"

			system "rails generate model ProviderLicense \
					license_number:string \
					license_effective_date:date \
					license_expiration_date:date \
					provider:references{polymorphic} \
					--skip-migration"

			system "rails generate model ProviderPaLicense \
					pa_license_effective_date:date \
					pa_license_expiration_date:date \
					provider:references{polymorphic} \
					--skip-migration"

			system "rails generate model ProviderNpLicense \
					np_license_number:string \
					np_license_effective_date:date \
					np_license_expiration_date:date \
					provider:references{polymorphic} \
					--skip-migration"

			system "rails generate model ProviderRnLicense \
					rn_license_number:string \
					rn_license_effective_date:date \
					rn_license_expiration_date:date \
					provider:references{polymorphic} \
					--skip-migration"
	end
end
