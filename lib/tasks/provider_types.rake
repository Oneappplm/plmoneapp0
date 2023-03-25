namespace :provider_types do
	desc "Add provider types seed data"
	task :seed_data => :environment do
		Import::ProviderTypesService.call(Rails.root.join('lib', 'data', 'provider-types.xlsx'))
	end
end
