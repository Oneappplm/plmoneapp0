class AppTrackersController < ProvidersController
	before_action :set_providers, only: [:index]
	before_action :set_provider, only: [:upload_documents, :delete_uploaded_document, :view_uploaded_documents]

	def index
	  @provider_personal_information = ProviderPersonalInformation.paginate(per_page: 10, page: params[:page] || 1)
	  @clients = Client.paginate(per_page: 10, page: params[:page] || 1)
	  @provider_personal_attempt = ProviderPersonalAttempt.new
	  @provider_personal_docs_receive = ProviderPersonalDocsReceive.new
	  @practice_information = PracticeInformation.new
	end

	# for uploading the documents
	def provider_personal_docs_uploaded_documents
		caqh_provider_id = params[:provider_personal_docs_upload][:caqh_provider_id]

		@documents = ProviderPersonalDocsUpload.where(caqh_provider_id: params[:caqh_provider_id])
		@document = ProviderPersonalDocsUpload.new

		if request.post?
			@document = ProviderPersonalDocsUpload.new(provider_personal_docs_upload_params)
			if @document.save
				redirect_to app_trackers_path, notice: 'Document uploaded successfully.'
			end
		end
	end

	# for provider_personal_attempt 
	def save_attempt_details
		@provider_personal_attempt = ProviderPersonalAttempt.new(attempt_params)
		if @provider_personal_attempt.save
			redirect_to app_trackers_path, notice: "Provider Personal Attempt created successfully."
		end
	end

	# for provider_personal_docs_receives in this update & create both methods are present
	def save_provider_personal_docs_receives
	  caqh_provider_id, provider_attest_id = params[:doc_recived_id].split(" ")

	  @provider_personal_docs_receive = ProviderPersonalDocsReceive.find_by(
	    caqh_provider_id: caqh_provider_id,
	    provider_attest_id: provider_attest_id
	  )

	  if @provider_personal_docs_receive.present?
	    if @provider_personal_docs_receive.update(provider_personal_docs_receive_params)
	      redirect_to app_trackers_path, notice: "Provider Personal Docs Receives updated successfully."
	    else
	      render :edit, alert: "Failed to update Provider Personal Docs Receives."
	    end
	  else
	    @provider_personal_docs_receive = ProviderPersonalDocsReceive.new(provider_personal_docs_receive_params)
	    if @provider_personal_docs_receive.save
	      redirect_to app_trackers_path, notice: "Provider Personal Docs Receives created successfully."
	    else
	      render :new, alert: "Failed to create Provider Personal Docs Receives."
	    end
	  end
	end

	
	# for provider_practice_informations in this update & create both methods are present
	def save_provider_practice_informations
	  if params[:doc_recived_id].present?
	    ids = params[:doc_recived_id].split(" ")
	    provider_attest_id = ids[0]
	    caqh_provider_practice_id = ids[1] if ids.size > 1
	  end

	  @practice_information = PracticeInformation.find_by(
	    caqh_provider_practice_id: caqh_provider_practice_id, 
	    provider_attest_id: provider_attest_id
	  )

	  if @practice_information
	    if @practice_information.update(practice_information_params)
	      redirect_to app_trackers_path, notice: 'Practice Information updated successfully.'
	    else
	      flash.now[:alert] = "Failed to update Practice Information."
	      render :edit
	    end
	  else
	    @practice_information = PracticeInformation.new(practice_information_params)
	    if @practice_information.save
	      redirect_to app_trackers_path, notice: 'Practice Information created successfully.'
	    else
	      flash.now[:alert] = "Failed to create Practice Information."
	      render :new
	    end
	  end
	end


	protected

	def provider_personal_docs_upload_params
		params.require(:provider_personal_docs_upload).permit(
			:file_upload,
			:provider_attest_id,
			:caqh_provider_attest_id,
			:caqh_provider_id,
			:provider_personal_information_id
		)
	end

	def attempt_params
		params.require(:provider_personal_attempt).permit(
			:provider_id,
			:provider_attest_id,
			:contact_method,
			:attempt_status,
			:contact_date,
			:comments
		)
	end

	def provider_personal_docs_receive_params
		params.require(:provider_personal_docs_receive).permit(
			:caqh_provider_id,
	    	:provider_attest_id,
	   		:application_received_date,
			:release_received_date,
			:disclosure_questions_explanation_received_date,
			:face_sheet_received_date,
			:employment_gap_received_date,
			:practice_information_received_date,
			:npdb_findings_explanation_received_date,
			:training_received_date,
			:education_received_date,
			:professional_resource_network_received_date,
			:dea_received_date,
			:pa_sponsor_request_form_received_date,
			:collaborative_agreement_received_date,
			:application_received_flag,
			:release_received_flag,
			:disclosure_questions_explanation_received_flag,
			:face_sheet_received_flag,
			:employment_gap_received_flag,
			:practice_information_received_flag,
			:npdb_findings_explanation_received_flag,
			:training_received_flag,
			:education_received_flag,
			:professional_resource_network_received_flag,
			:dea_received_flag,
			:pa_sponsor_request_form_received_flag,
			:collaborative_agreement_received_flag,
			:application_received_incomplete_flag,
			:release_received_incomplete_flag,
			:disclosure_questions_explanation_received_incomplete_flag,
			:face_sheet_received_incomplete_flag,
			:employment_gap_received_incomplete_flag,
			:practice_information_received_incomplete_flag,
			:npdb_findings_explanation_received_incomplete_flag,
			:training_received_incomplete_flag,
			:education_received_incomplete_flag,
			:professional_resource_network_received_incomplete_flag,
			:dea_received_incomplete_flag,
			:pa_sponsor_request_form_received_incomplete_flag,
			:collaborative_agreement_received_incomplete_flag,
			:application_comments,
			:release_comments,
			:disclosure_questions_explanation_comments,
			:face_sheet_comments,
			:employment_gap_comments,
			:practice_information_comments,
			:npdb_findings_explanation_comments,
			:training_comments,
			:education_comments,
			:professional_resource_network_comments,
			:dea_comments,
			:pa_sponsor_request_form_comments,
			:collaborative_agreement_comments
	   )
	end

	def practice_information_params
		params.require(:practice_information).permit(
			:caqh_provider_practice_id,
			:provider_attest_id,
			:caqh_provider_attest_id,
			:practice_name,
			:address,
			:address2,
			:city,
			:state,
			:zip,
			:ext_zip,
			:county,
			:phone_number,
			:after_hours_phone_number,
			:fax_number,
			:email_address,
			:correspondence_flag,
			:partners_flag,
			:other_associates_flag,
			:currently_practicing_flag,
			:start_date,
			:coverage24x7_flag,
			:practice_limitation_flag,
			:ada_approved_flag,
			:minority_business_flag,
			:interpreter_available_flag,
			:medicare_number,
			:medicaid_number,
			:epsdt_certified_flag,
			:epsdt_number,
			:practice_organization_type,
			:phone_number2,
			:patient_appointment_phone_number,
			:answering_service_phone_number,
			:pager_beeper_number,
			:list_in_directory_flag,
			:w9_practice_name,
			:in_practice_flag,
			:practice_intention_explanation,
			:emergency_phone_number,
			:practice_description,
			:patients_enrolled,
			:patient_visits,
			:appointments_per_hour,
			:average_waiting_time,
			:call_response_time,
			:electronic_billing_flag,
			:bwc_number,
			:workers_compensation_risk_number,
			:ownership_description,
			:emergency_procedure,
			:npi,
			:practice_type_description,
			:service_type_description,
			:department_name,
			:cell_phone_number,
			:pager_beeper_number2,
			:end_date,
			:phone_extension,
			:patient_appointment_phone_extension,
			:answering_service_phone_extension,
			:correspondence_method,
			:address_type_address_type_description,
			:country,
			:office_manager,
			:manager_phone_number,
			:manager_fax_number,
			:back_office_phone_number,
			:type_of_practice,
			:mail_stop,
			:hospital_based_department_name,
			:practice_type,
			:group_name,
			:group_number_with_tax_id,
			:name_affiliated_with_tax_id,
			:federal_tax_id,
			:number_of_patients_weekly,
			:total_number_of_patients,
			:total_medicare_patients,
			:total_medical_medicaid_patients,
			:is_ccs,
			:is_chdp,
			:any_allied_health_practitioner,
			:physician_to_nurse_ratio,
			:physician_to_midwife_ratio,
			:physician_to_assistant_ratio,
			:is_employing_any_personal_practitioner,
			:is_licensed_member_in_practice,
			:is_staff_speak_any_foreign_language,
			:radiology_services,
			:allergy_injections,
			:age_approriate_immunizations,
			:osteopathic_manipulations,
			:ekg,
			:allergy_skin_tests,
			:flexible_sigmoidoscopy,
			:iv_hydration_treatments,
			:care_of_minor_lacerations,
			:routine_office_gynecology,
			:tympanometry_audiometry_tests,
			:cardiac_stress_tests,
			:pulmonary_function_tests,
			:drawing_blood,
			:asthma_treatmeant,
			:physical_therapies,
			:other_surgical_services,
			:clinical_services_performed_not_typically_associated,
			:clinical_services_not_performed_typically_associated,
			:has_practice_limit_age,
			:practice_limit_age_from,
			:practice_limit_age_to,
			:has_limited_gender,
			:limited_gender,
			:other_limitations,
			:computer_office,
			:computer_office_has_other,
			:computer_office_other,
			:operating_system,
			:has_os_office_other,
			:os_office_other,
			:has_computer_has_internet_access,
			:does_participate_edi,
			:edi_network,
			:has_practice_management_software,
			:practice_management_software,
			:does_perform_surgery,
			:anesthesia_local,
			:anesthesia_regional,
			:anesthesia_conscious_sedation,
			:anesthesia_general,
			:anesthesia_other,
			:anesthesia_other_value,
			:anesthesia_none,
			:ambulatory_surgery_facilities,
			:health_surgery_licensure,
			:ambulatory_health_care,
			:medicare_certification,
			:medical_quality_commission,
			:other_certification,
			:other_certification_explanation,
			:certification_none,
			:is_laboratory_services,
			:billing_name,
			:tax_id,
			:type_of_service,
			:clia_waiver,
			:clia_certificate,
			:clia_certificate_number,
			:clia_certificate_expiration_date,
			:clia_certification_of_participation,
			:other_clia,
			:xray_certification_type,
			:coverage_24_hour,
			:answering_service,
			:voice_mail_with_instruction,
			:voice_mail_with_other_instruction,
			:answering_service_company,
			:answering_service_fax_number,
			:answering_service_mail_address,
			:answering_service_mail_stop,
			:answering_service_address2,
			:answering_service_city,
			:answering_service_country,
			:answering_service_state,
			:answering_service_zipcode,
			:any_cover_practitioner,
			:ada_accessibility,
			:handicapped_building,
			:handicapped_parking,
			:handicapped_restroom,
			:handicapped_other,
			:handicapped_other_explaination,
			:disabled_telephony,
			:american_sign_language,
			:disabled_impairment_services,
			:disabled_other,
			:disabled_other_explaination,
			:other_communication_system,
			:public_transportation,
			:public_bus,
			:public_subway,
			:public_regional_train,
			:public_other_transportation,
			:public_other_transportation_explaination,
			:is_provide_child_care_service,
			:is_tdd,
			:is_epsdt_certified,
			:epsdt_certificate_number,
			:is_directory_location_listed,
			:is_minority_business_enterprise,
			:group_npi,
			:is_primary_location,
			:any_comments,
			:mon_time_from,
			:mon_time_to,
			:mon_closed,
			:tue_time_from,
			:tue_time_to,
			:tue_closed,
			:wed_time_from,
			:wed_time_to,
			:wed_closed,
			:thu_time_from,
			:thu_time_to,
			:thu_closed,
			:fri_time_from,
			:fri_time_to,
			:fri_closed,
			:sat_time_from,
			:sat_time_to,
			:sat_closed,
			:sun_time_from,
			:sun_time_to,
			:sun_closed,
			:holiday_time_from,
			:holiday_time_to,
			:holiday_closed
		)
	end

	def set_providers
		if params[:user_search].present?
			search_term = params[:user_search].strip.downcase
			@providers = Provider.unscoped.where("
				LOWER(first_name) LIKE :search OR
				LOWER(last_name) LIKE :search OR
				LOWER(middle_name) LIKE :search OR
				LOWER(npi) LIKE :search OR
				CONCAT(LOWER(first_name), ' ', LOWER(last_name)) LIKE :search OR
				CONCAT(LOWER(first_name), ' ', LOWER(middle_name), ' ', LOWER(last_name)) LIKE :search
			", search: "%#{search_term}%")
		else
			@providers = Provider.unscoped
		end
	end

	def set_provider
		@provider = Provider.find_by_id params.dig(:id)
	end
end
