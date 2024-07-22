class MultiSelectDataController < ApplicationController
	def states
		payer_state = params[:payer_state]
    if ['selected_state'].include?(payer_state)
      enrollment_provider = EnrollmentProvider.find_by(id: enrollment_provider_id)
      send_result State.all.map{ |state| { label: "#{state.name} - #{state.alpha_code}", value: state.alpha_code } }, selected_state: enrollment_provider&.payer_state
    elsif ['selected_state'].include?(payer_state)
      enroll_group_id = params[:enroll_group_id]
      enroll_group = EnrollGroup.find_by(id: enroll_group_id)
      send_result State.all.map{ |state| { label: "#{state.name} - #{state.alpha_code}", value: state.alpha_code } }, selected_state: enroll_group&.payer_state
    else
			send_result State.all.map{ |state| { label: "#{state.name} - #{state.alpha_code}", value: state.alpha_code } }
    end
	end

  def provider_states
    provider_state = params[:provider_state]
    if ['selected_state_id'].include?(provider_state)
      provider = Provider.find_by(id: enrollment_provider_id)
      send_result State.all.map{ |state| { label: "#{state.name} - #{state.alpha_code}", value: state.id } }, selected_state: provider&.state_id
    elsif ['birth_state'].include?(provider_state)
      provider = Provider.find_by(id: enrollment_provider_id)
      send_result State.all.map{ |state| { label: "#{state.name} - #{state.alpha_code}", value: state.id } }, selected_state: provider&.birth_state 
    else
      send_result State.all.map{ |state| { label: "#{state.name} - #{state.alpha_code}", value: state.id } }
    end
  end

	def payor_names
		send_result payor_names = PayorName.all.map{|m| { label: m.title, value: m.title} }
  end

	def enrollment_provivder_enrollment_status
		send_result [
	  	{ label: 'Application Not Submitted', value: 'application-not-submitted'},
      { label: 'Application Submitted', value: 'application-submitted' },
      { label: 'Processing', value: 'processing' },
      { label: 'Approved', value: 'approved'},
      { label: 'Denied', value: 'denied' },
      { label: 'Terminated', value: 'terminated' },
	  	{ label: 'Not Eligible', value: 'not-eligible' },
	  	{ label: 'Revalidation', value: 'revalidation' },
		  { label: 'Not Part of Contract', value: 'none-contract' }
    ], selected_enrollment_status: params[:current_enrollment_status]
  end

	def enrollment_provivder_enrollment_type
		send_result EnrollmentProvider.enrollment_types.map{|type| { label: type[0], value: type[1]} }, selected_enrollment_type: params[:current_enrollment_type]
  end

  def group_states
    send_result State.all.map{ |state| { label: "#{state.name} - #{state.alpha_code}", value: state.name } }
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
			if params[:without_enrollments].present? && params[:without_enrollments] == "true"
				if params[:action_name] == "new" || (params[:action_name] == "edit" && !enrollment_provider&.provider_id.present?)
					send_result ProviderSource.where("NOT EXISTS (SELECT 1 FROM enrollment_providers WHERE enrollment_providers.provider_id = provider_sources.id AND enrollment_providers.outreach_type = 'provider-from-provider-app')").map	{ |provider_source| { label: provider_source.provider_name, value: provider_source.id } }, selected_provider: enrollment_provider&.provider_id
				else
					send_result ProviderSource.where("NOT EXISTS (SELECT 1 FROM enrollment_providers WHERE enrollment_providers.provider_id = provider_sources.id AND enrollment_providers.outreach_type = 'provider-from-provider-app' AND provider_sources.id <> #{enrollment_provider.provider_id})").map	{ |provider_source| { label: provider_source.provider_name, value: provider_source.id } }, selected_provider: enrollment_provider&.provider_id
				end
			else
				send_result ProviderSource.all.map	{ |provider_source| { label: provider_source.provider_name, value: provider_source.id } }, selected_provider: enrollment_provider&.provider_id
			end
		elsif outreach_type == 'provider-from-enrollment'
			if params[:without_enrollments].present? && params[:without_enrollments] == "true"
				if params[:action_name] == "new" || (params[:action_name] == "edit" && !enrollment_provider&.provider_id.present?)
					@providers = Provider.where("NOT EXISTS (SELECT 1 FROM enrollment_providers WHERE enrollment_providers.provider_id = providers.id AND enrollment_providers.outreach_type = 'provider-from-enrollment')")
				else
					@providers = Provider.where("NOT EXISTS (SELECT 1 FROM enrollment_providers WHERE enrollment_providers.provider_id = providers.id AND enrollment_providers.outreach_type = 'provider-from-enrollment' AND providers.id <> #{enrollment_provider.provider_id})")
				end
			else
				@providers = Provider.all
			end

			if !current_user.can_access_all_groups? && !current_user.super_administrator?
				send_result @providers.where(enrollment_group_id: current_user.enrollment_groups.pluck(:id)).map { |provider| { label: provider.provider_name, value: provider.id } }, selected_provider: enrollment_provider&.provider_id
			else
				send_result @providers.map { |provider| { label: provider.provider_name, value: provider.id } }, selected_provider: enrollment_provider&.provider_id
			end
		else
			send_result Provider.all.map { |provider| { label: provider.provider_name, value: provider.id } }, selected_provider: enrollment_provider&.provider_id
		end
	end

	def enrollment_payers
    enrollment_payer = params[:enrollment_payer]
    if ['selected_enrollment_payer'].include?(enrollment_payer)
      enrollment_provider = EnrollmentProvider.find_by(id: enrollment_provider_id)
      send_result EnrollmentPayer.all.map { |m| { label: m.name, value: m.name } }, selected_enrollment_payer: enrollment_provider&.enrollment_payer
    elsif ['selected_enrollment_payor'].include?(enrollment_payer)
      enroll_group_id = params[:enroll_group_id]
      enroll_group = EnrollGroup.find_by(id: enroll_group_id)
      send_result EnrollmentPayer.all.map { |m| { label: m.name, value: m.name } }, selected_enrollment_payor: enroll_group&.enrollment_payer
    else
      send_result EnrollmentPayer.all.map { |m| { label: m.name, value: m.name } }
    end
  end

	def board_names
		send_result	BoardName.all.map{|board| { label: board.name, value: board.name} }
	end

	def serviced_populations
		send_result	ServicedPopulation.all.map(&:name)
	end

	def method_resolutions
		send_result	MethodResolution.all.map(&:name)
  end
	# add more methods here

	private

	def send_result data, **options
		render json: { result: data, options: options }
	end
end
