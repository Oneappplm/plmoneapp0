class MultiSelectDataController < ApplicationController
	def states
		send_result State.all.map{ |state| { label: "#{state.name} - #{state.alpha_code}", value: state.alpha_code } }
	end

	def provider_types
		send_result ProviderType.all.map{|ptype| { label: ptype.fch, value: ptype.fch} }
	end

	def	countries
		send_result Country.all_translated.map{|country| { label: country, value: country} }
	end

	def visa_types
		send_result VisaType.all.map{|visa| { label: visa.name, value: visa.name} }
	end

	def languages
		send_result	Language.all.map(&:name)
	end

	def health_plans
		send_result	HealthPlan.all.map(&:name)
	end

	def hospitals
		send_result	Hospital.all.map(&:name)
	end

	def directories
		send_result	Directory.all.map(&:name)
	end

	def specialties
		send_result	Specialty.all.map{|specialty| { label: specialty.bcbs, value: specialty.bcbs} }
	end

	def training_types
		send_result	TrainingType.all.map{|training_type| { label: training_type.name, value: training_type.name} }
	end

	def privilege_statuses
		send_result	PrivilegeStatus.all.map{|privilege| { label: privilege.name, value: privilege.name} }
	end

	def providers
		enrollment_provider_id = params[:enrollment_provider_id]
		enrollment_provider = EnrollmentProvider.find_by(id: enrollment_provider_id)
		outreach_type = params[:outreach_type]
		if outreach_type == 'provider-from-provider-app'
			send_result ProviderSource.all.map	{ |provider_source| { label: provider_source.provider_name, value: provider_source.id } }, selected_provider: enrollment_provider&.provider_id
		else
			send_result Provider.all.map { |provider| { label: provider.provider_name, value: provider.id } }, selected_provider: enrollment_provider&.provider_id
		end
	end
	# add more methods here

	private

	def send_result data, **options
		render json: { result: data, options: options }
	end
end
