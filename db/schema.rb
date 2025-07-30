# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2025_07_23_103431) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "add_schedules", force: :cascade do |t|
    t.string "group_name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "add_members", default: [], array: true
  end

  create_table "admitting_arrangements", force: :cascade do |t|
    t.bigint "provider_source_id", null: false
    t.string "physician_practice_name"
    t.string "facility_name"
    t.string "facility_address_line1"
    t.string "facility_address_line2"
    t.string "facility_city"
    t.string "facility_zipcode"
    t.text "explanation"
    t.string "admitting_physician_practice_clinic_group"
    t.string "admit_state"
    t.text "admitting_arrangements"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_source_id"], name: "index_admitting_arrangements_on_provider_source_id"
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.bigint "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.float "latitude"
    t.float "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.string "app_version"
    t.string "os_version"
    t.string "platform"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
  end

  create_table "allied_health_practitioners", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "suffix"
    t.string "type_of_practitioner"
    t.string "mail_stop"
    t.string "address"
    t.string "address2"
    t.string "city"
    t.string "county"
    t.string "state"
    t.string "zip_code"
    t.string "country"
    t.string "state_license_number"
    t.boolean "listed_as_pcp", default: false
    t.bigint "practice_information_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["practice_information_id"], name: "index_allied_health_practitioners_on_practice_information_id"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "audittrail_sendreadyfordownload", id: false, force: :cascade do |t|
    t.integer "id"
    t.string "CreateDate", limit: 50
    t.string "PractitionerGuid", limit: 50
    t.string "ClientGuid", limit: 50
  end

  create_table "billing_companies", force: :cascade do |t|
    t.string "billing_company_name"
    t.string "address"
    t.string "suite"
    t.string "additional_address"
    t.string "city"
    t.string "county"
    t.string "state"
    t.string "zip"
    t.string "country"
    t.string "phone_number"
    t.string "contact"
    t.string "fax_number"
    t.string "email"
    t.string "name_affiliated_with_tax_id"
    t.string "federal_tax_id"
    t.string "check_payable_to"
    t.boolean "bills_electronically"
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "board_names", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "certifications", force: :cascade do |t|
    t.string "certification_type"
    t.string "issuing_agency"
    t.string "certification_status"
    t.string "certification_number"
    t.date "initial_certification_date"
    t.date "recertification_dates"
    t.date "certification_expiration_date"
    t.boolean "does_not_expire"
    t.text "comments"
    t.boolean "show_on_tickler"
    t.integer "caqh_provider_attest_id"
    t.bigint "provider_attest_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "audit_status"
    t.integer "caqh_provider_certification_id"
    t.index ["provider_attest_id"], name: "index_certifications_on_provider_attest_id"
  end

  create_table "client_organizations", force: :cascade do |t|
    t.string "organization_name"
    t.string "organization_type"
    t.string "organization_npi"
    t.string "organization_address_1"
    t.string "organization_address_2"
    t.string "organization_city"
    t.integer "organization_state_id"
    t.string "organization_zipcode"
    t.string "organization_phone_number"
    t.string "organization_fax_number"
    t.string "organization_dba_name"
    t.string "organization_tax_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "primary_service"
    t.string "tin_number"
    t.string "tin_name"
    t.string "organization_facility_type"
    t.integer "credential", default: 0, null: false
    t.integer "recredential", default: 0, null: false
    t.string "contact_method"
    t.string "contact_first_name"
    t.string "contact_middle_name"
    t.string "contact_last_name"
    t.string "contact_suffix"
    t.string "email_address"
    t.string "mail_stop"
    t.string "organization_country"
    t.date "client_due_date"
    t.date "client_batch_date"
    t.string "client_batch_name"
    t.string "client_batch_id"
  end

  create_table "client_provider_enrollments", force: :cascade do |t|
    t.string "enrollable_type", null: false
    t.bigint "enrollable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollable_type", "enrollable_id"], name: "index_client_provider_enrollments_on_enrollable"
  end

  create_table "clients", force: :cascade do |t|
    t.string "full_name"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "provider_name"
    t.date "birth_date"
    t.string "state"
    t.string "state_abbr"
    t.string "street_address"
    t.string "city"
    t.string "zipcode"
    t.date "attested_date"
    t.string "npi"
    t.string "ssn"
    t.string "provider_type"
    t.string "specialty"
    t.string "tin"
    t.string "entity"
    t.string "cred_status"
    t.string "cred_cycle"
    t.string "vrc_status"
    t.string "psv_flat"
    t.string "medv_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "prefix"
    t.string "suffix"
    t.string "gender"
    t.string "prac_type"
    t.string "specialty_name"
    t.string "address1"
    t.string "address2"
    t.string "state_or_province"
    t.string "country"
    t.string "postal_code"
    t.string "primary_phone"
    t.string "primary_email"
    t.string "client_specified_id"
    t.string "practitioner_guid"
    t.string "client_guid"
    t.string "file_path"
    t.string "signature_date"
    t.string "file_status"
    t.string "app_receive_date"
    t.string "app_receive_complete_date"
    t.string "app_complete_date"
    t.string "approval_date"
    t.string "cred_or_recred"
    t.string "org_type"
    t.string "caqhid"
    t.string "import_exid"
    t.string "client_id"
    t.string "external_id"
  end

  create_table "covering_practitioners", force: :cascade do |t|
    t.string "practitioner_name"
    t.string "facility"
    t.string "address"
    t.string "mail_stop"
    t.string "address2"
    t.string "city"
    t.string "country"
    t.string "state"
    t.string "zipcode"
    t.string "phone_number"
    t.string "fax_number"
    t.string "email_address"
    t.bigint "practice_information_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["practice_information_id"], name: "index_covering_practitioners_on_practice_information_id"
  end

  create_table "dea_webcrawler_logs", force: :cascade do |t|
    t.string "filetype"
    t.string "filepath"
    t.string "status"
    t.bigint "rva_information_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rva_information_id"], name: "index_dea_webcrawler_logs_on_rva_information_id"
  end

  create_table "director_providers", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "virtual_review_committee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "provider_personal_information_id"
    t.index ["provider_personal_information_id"], name: "index_director_providers_on_provider_personal_information_id"
    t.index ["user_id"], name: "index_director_providers_on_user_id"
    t.index ["virtual_review_committee_id"], name: "index_director_providers_on_virtual_review_committee_id"
  end

  create_table "directories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "disclosure_categories", force: :cascade do |t|
    t.string "title"
    t.string "note"
    t.string "alert_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "disclosure_questions", force: :cascade do |t|
    t.bigint "disclosure_category_id"
    t.text "question"
    t.string "slug"
    t.string "note"
    t.string "alert_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["disclosure_category_id"], name: "index_disclosure_questions_on_disclosure_category_id"
  end

  create_table "education_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "egd_logs", force: :cascade do |t|
    t.bigint "enroll_groups_detail_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enroll_groups_detail_id"], name: "index_egd_logs_on_enroll_groups_detail_id"
  end

  create_table "enroll_groups", force: :cascade do |t|
    t.string "name"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "suffix"
    t.string "email"
    t.string "telephone_number"
    t.string "medicare_ptan"
    t.string "medicaid_group_number"
    t.string "bcbs_number"
    t.string "tricate_military"
    t.string "commercial_name"
    t.string "contracted"
    t.string "revalidated"
    t.string "revalidated_payer_name"
    t.string "application_contracts"
    t.string "application_payer_name"
    t.string "with_medicare"
    t.string "with_eft"
    t.string "with_edi"
    t.datetime "start_date"
    t.datetime "due_date"
    t.string "payer"
    t.datetime "revalidation_date"
    t.string "enrollment_type"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "group_id"
    t.integer "user_id"
    t.string "outreach_type"
    t.string "enrollment_payer"
    t.string "voided_bank_letter"
    t.integer "dco"
  end

  create_table "enroll_groups_details", force: :cascade do |t|
    t.bigint "enroll_group_id"
    t.date "start_date"
    t.date "due_date"
    t.string "enrollment_payer"
    t.string "enrollment_type"
    t.string "enrollment_status"
    t.string "ptan_number"
    t.date "approved_date"
    t.date "revalidation_date"
    t.date "revalidation_due_date"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "state_id"
    t.string "group_number"
    t.datetime "effective_date"
    t.string "application_status"
    t.string "payor_type"
    t.string "medicare_tricare"
    t.string "payor_name"
    t.string "payor_phone"
    t.string "payor_email"
    t.string "enrollment_link"
    t.string "payor_username"
    t.string "password"
    t.string "payor_question"
    t.string "payor_answer"
    t.string "portal_admin"
    t.string "portal_admin_name"
    t.string "portal_admin_phone"
    t.string "portal_admin_email"
    t.string "caqh_payer"
    t.string "eft"
    t.string "era"
    t.string "client_notes"
    t.string "notes"
    t.string "password_digest"
    t.string "payer_state"
    t.string "payor_submission_type"
    t.string "payor_link"
    t.string "portal_username"
    t.string "portal_password"
    t.json "upload_payor_file"
    t.index ["enroll_group_id"], name: "index_enroll_groups_details_on_enroll_group_id"
  end

  create_table "enroll_groups_details_questions", force: :cascade do |t|
    t.integer "enroll_groups_detail_id"
    t.string "secret_question"
    t.string "answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "enrollment_comments", force: :cascade do |t|
    t.bigint "enrollment_provider_id"
    t.bigint "enroll_group_id"
    t.bigint "provider_id"
    t.bigint "user_id"
    t.string "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enroll_group_id"], name: "index_enrollment_comments_on_enroll_group_id"
    t.index ["enrollment_provider_id"], name: "index_enrollment_comments_on_enrollment_provider_id"
    t.index ["provider_id"], name: "index_enrollment_comments_on_provider_id"
    t.index ["user_id"], name: "index_enrollment_comments_on_user_id"
  end

  create_table "enrollment_group_deleted_doc_logs", force: :cascade do |t|
    t.bigint "enrollment_group_id", null: false
    t.string "document_key"
    t.string "title"
    t.string "note"
    t.string "deleted_by"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_group_id"], name: "index_enrollment_group_deleted_doc_logs_on_enrollment_group_id"
  end

  create_table "enrollment_group_svc_locations", force: :cascade do |t|
    t.bigint "enrollment_group_id"
    t.string "primary_service_non_office_area"
    t.string "primary_service_location_apps"
    t.string "primary_service_zip_code"
    t.string "primary_service_office_email"
    t.string "primary_service_fax"
    t.string "primary_service_office_website"
    t.string "primary_service_crisis_phone"
    t.string "primary_service_location_other_phone"
    t.string "primary_service_appt_scheduling"
    t.string "primary_service_interpreter_language"
    t.string "primary_service_telehealth_only_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_group_id"], name: "index_enrollment_group_svc_locations_on_enrollment_group_id"
  end

  create_table "enrollment_groups", force: :cascade do |t|
    t.string "group_name"
    t.string "group_code"
    t.string "office_address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "phone_number"
    t.string "ext"
    t.string "fax_number"
    t.string "business_group", default: "no"
    t.string "legal_business_name"
    t.string "another_business_name", default: "no"
    t.string "other_business_name"
    t.string "other_business_type"
    t.string "specify_type_of_group"
    t.string "shared_tin", default: "no"
    t.string "tin_file"
    t.string "specify_type_of_group_file"
    t.string "npi_digit_type"
    t.string "npi_digit_type_group"
    t.string "provider_type"
    t.string "po_box"
    t.string "po_box_city"
    t.string "po_box_state"
    t.string "po_box_zip_code"
    t.string "ca_po_box_address"
    t.string "ca_po_box_city"
    t.string "ca_po_box_state"
    t.string "ca_po_box_zip_code"
    t.string "individual_ownership"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tin_digit"
    t.string "tin_digit_irs"
    t.string "w9_file"
    t.string "cp575_file"
    t.string "specific_type_file"
    t.string "ownership_file"
    t.string "payer_contracts"
    t.string "group_type_documents"
    t.string "eft_file"
    t.string "voided_check_file"
    t.string "flatform"
    t.date "w9_signed_date"
    t.date "w9_sign_date_expiration"
    t.date "void_check_signed_date"
    t.date "void_check_date_expiration"
    t.date "bank_letter_signed_date"
    t.date "bank_letter_date_expiration"
    t.string "telehealth_providers"
    t.string "admitting_privileges"
    t.string "name_admitting_physician"
    t.string "facility_location"
    t.string "facility_name"
    t.string "admitting_facility_address_line1"
    t.string "admitting_facility_address_line2"
    t.string "admitting_facility_city"
    t.string "admitting_facility_state"
    t.string "admitting_facility_zip_code"
    t.string "admitting_facility_arrangments"
    t.string "remmitance_contact_name"
    t.string "remmitance_contact_number"
    t.string "remmitance_contact_email"
    t.string "billing_contact_name"
    t.string "billing_contact_number"
    t.string "billing_contact_email"
    t.datetime "qualifacts_contract_effective_date"
    t.date "new_group_notification"
    t.date "noti_group_start_date"
    t.date "noti_welcome_letter_sent"
    t.date "notification_enrollment_submit_group"
    t.string "noti_group_services"
    t.string "noti_status"
    t.date "noti_work_end_date"
    t.boolean "welcome_letter_status", default: false
    t.string "welcome_letter_subject"
    t.text "welcome_letter_message"
    t.json "welcome_letter_attachments"
    t.string "group_note"
    t.boolean "check_welcome_letter", default: false
    t.boolean "check_co_caqh", default: false
    t.boolean "check_mn_caqh_state_release_form", default: false
    t.boolean "check_mn_caqh_authorization_form", default: false
    t.boolean "check_caqh_standard_authorization", default: false
    t.string "billing_address_autofill"
    t.string "remittance_address_autofill"
    t.datetime "welcome_letter_sent_at"
  end

  create_table "enrollment_groups_contact_details", force: :cascade do |t|
    t.bigint "enrollment_group_id"
    t.string "group_personnel_name"
    t.string "group_personnel_email"
    t.string "group_personnel_phone_number"
    t.string "group_personnel_fax_number"
    t.string "group_personnel_position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_group_id"], name: "index_enrollment_groups_contact_details_on_enrollment_group_id"
  end

  create_table "enrollment_groups_details", force: :cascade do |t|
    t.bigint "enrollment_group_id"
    t.string "individual_ownership_first_name"
    t.string "individual_ownership_middle_name"
    t.string "individual_ownership_last_name"
    t.string "individual_ownership_title"
    t.string "individual_ownership_ssn"
    t.string "individual_ownership_dob"
    t.string "individual_ownership_percent_of_ownership"
    t.date "individual_ownership_effective_date"
    t.date "individual_ownership_control_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "roles"
    t.string "email_address"
    t.string "group_role"
    t.index ["enrollment_group_id"], name: "index_enrollment_groups_details_on_enrollment_group_id"
  end

  create_table "enrollment_payers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "enrollment_providers", force: :cascade do |t|
    t.string "name"
    t.datetime "start_date"
    t.datetime "due_date"
    t.string "enrollment_payer"
    t.datetime "revalidation_date"
    t.string "enrollment_type"
    t.datetime "state_license_submitted"
    t.string "state_license_file"
    t.datetime "dea_submitted"
    t.string "dea_file"
    t.datetime "irs_letter_submitted"
    t.string "irs_letter_file"
    t.datetime "w9_submitted"
    t.string "w9_file"
    t.datetime "voided_check_submitted"
    t.string "voided_check_file"
    t.datetime "curriculum_vitae_submitted"
    t.string "curriculum_vitae_file"
    t.datetime "cms_460_submitted"
    t.string "cms_460_file"
    t.datetime "eft_submitted"
    t.string "eft_file"
    t.datetime "cert_insurance_submitted"
    t.string "cert_insurance_file"
    t.datetime "driver_license_submitted"
    t.string "driver_license_file"
    t.datetime "board_certification_submitted"
    t.string "board_certification_file"
    t.string "status", default: "pending"
    t.string "application_id"
    t.string "not_submitted_note"
    t.string "not_submitted_note_rejected"
    t.datetime "approved_date"
    t.string "approved_confirmation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "provider_id"
    t.integer "user_id"
    t.string "outreach_type"
    t.string "enrolled_by"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "suffix"
    t.string "telephone_number"
    t.string "email_address"
    t.string "updated_by"
  end

  create_table "enrollment_providers_details", force: :cascade do |t|
    t.bigint "enrollment_provider_id"
    t.date "start_date"
    t.date "due_date"
    t.string "enrollment_payer"
    t.string "enrollment_type"
    t.string "enrollment_status"
    t.string "ptan_number"
    t.date "approved_date"
    t.date "revalidation_date"
    t.date "revalidation_due_date"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider_ptan"
    t.string "group_ptan"
    t.integer "enrollment_tracking_id"
    t.string "enrollment_effective_date"
    t.string "association_start_date"
    t.string "business_end_date"
    t.string "association_end_date"
    t.string "line_of_business"
    t.string "revalidation_status"
    t.string "cpt_code"
    t.string "descriptor"
    t.string "provider_id"
    t.string "group_id"
    t.string "payer_state"
    t.json "upload_payor_file"
    t.string "payor_username"
    t.string "payor_password"
    t.string "processing_date"
    t.string "terminated_date"
    t.date "denied_date"
    t.string "payer_state"
    t.index ["enrollment_provider_id"], name: "index_enrollment_providers_details_on_enrollment_provider_id"
  end

  create_table "epd_logs", force: :cascade do |t|
    t.bigint "enrollment_providers_detail_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_providers_detail_id"], name: "index_epd_logs_on_enrollment_providers_detail_id"
  end

  create_table "epd_questions", force: :cascade do |t|
    t.bigint "enrollment_providers_detail_id", null: false
    t.string "question"
    t.string "answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_providers_detail_id"], name: "index_epd_questions_on_enrollment_providers_detail_id"
  end

  create_table "graduate_details", force: :cascade do |t|
    t.bigint "provider_source_id", null: false
    t.string "education_type"
    t.string "location"
    t.string "professional_school_name"
    t.string "address_line1"
    t.string "address_line2"
    t.string "city"
    t.string "zip_code"
    t.string "telephone_number"
    t.string "telephone_ext"
    t.string "fax_number"
    t.string "email"
    t.string "graduate_type"
    t.string "specialization"
    t.string "degree_awarded"
    t.string "faculty_director_first_name"
    t.string "faculty_director_last_name"
    t.string "director_degree"
    t.date "start_date"
    t.date "graduation_date"
    t.string "incomplete_education_reason"
    t.boolean "education_completed", default: true
    t.boolean "ecfmg_certified"
    t.string "ecfmg_number"
    t.date "ecfmg_issue_date"
    t.date "ecfmg_valid_through"
    t.boolean "ecfmg_permanent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_source_id"], name: "index_graduate_details_on_provider_source_id"
  end

  create_table "group_contacts", force: :cascade do |t|
    t.bigint "group_dco_id"
    t.string "department"
    t.string "name"
    t.string "role"
    t.string "phone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "enrollment_group_id"
    t.index ["enrollment_group_id"], name: "index_group_contacts_on_enrollment_group_id"
    t.index ["group_dco_id"], name: "index_group_contacts_on_group_dco_id"
  end

  create_table "group_dco_notes", force: :cascade do |t|
    t.bigint "group_dco_id"
    t.string "title"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_dco_id"], name: "index_group_dco_notes_on_group_dco_id"
  end

  create_table "group_dco_old_location_addresses", force: :cascade do |t|
    t.bigint "group_dco_id", null: false
    t.string "old_address"
    t.string "old_city"
    t.string "old_state"
    t.string "old_zipcode"
    t.string "old_county"
    t.boolean "is_old_location_primary", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "effective_date"
    t.index ["group_dco_id"], name: "index_group_dco_old_location_addresses_on_group_dco_id"
  end

  create_table "group_dco_provider_outreach_informations", force: :cascade do |t|
    t.bigint "group_dco_id"
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "fax"
    t.string "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_dco_id"], name: "index_group_dco_provider_outreach_informations_on_group_dco_id"
  end

  create_table "group_dco_schedules", force: :cascade do |t|
    t.bigint "group_dco_id"
    t.string "day"
    t.string "start_time"
    t.string "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_dco_id"], name: "index_group_dco_schedules_on_group_dco_id"
  end

  create_table "group_dcos", force: :cascade do |t|
    t.bigint "enrollment_group_id", null: false
    t.string "client"
    t.string "dco_name"
    t.string "dco_address"
    t.string "dco_city"
    t.string "state"
    t.string "dco_zipcode"
    t.string "county"
    t.string "service_location_phone_number"
    t.string "service_location_fax_number"
    t.string "panel_status_to_new_patients"
    t.string "panel_age_limit"
    t.string "include_in_directory"
    t.string "dco_provider_name"
    t.string "dco_provider_email"
    t.string "dco_provider_phone_number"
    t.string "dco_provider_fax_number"
    t.string "dco_provider_position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "inpatient_facility"
    t.string "is_clinic"
    t.string "telehealth_provider"
    t.string "old_address"
    t.string "old_city"
    t.string "old_state"
    t.string "old_county"
    t.string "old_zipcode"
    t.boolean "is_old_location_primary"
    t.string "website"
    t.string "tax_id"
    t.string "facility_billing_npi"
    t.string "mn_medicaid_number"
    t.string "wi_medicaid_number"
    t.string "medicare_id_ptan"
    t.string "taxonomy"
    t.string "telehealth_video_conferencing_technology"
    t.string "is_gender_affirming_treatment"
    t.string "panel_size"
    t.string "medicare_authorized_official"
    t.string "collab_name"
    t.string "collab_npi"
    t.boolean "is_primary_location"
    t.date "effective_date"
    t.string "location_status"
    t.string "location_npi"
    t.string "location_tin"
    t.string "npi_digits"
    t.string "tin_digits_type"
    t.string "specialty"
    t.index ["enrollment_group_id"], name: "index_group_dcos_on_enrollment_group_id"
  end

  create_table "group_engage_providers", force: :cascade do |t|
    t.integer "practice_location_id"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.datetime "date_of_birth"
    t.string "email_address"
    t.string "ssn"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "group_roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "health_plans", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "help_codes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
    t.string "code"
    t.string "description"
  end

  create_table "hospital_privileges", force: :cascade do |t|
    t.bigint "provider_source_id", null: false
    t.string "state_abbr"
    t.string "hp_facility_name"
    t.boolean "hp_no_longer_in_business"
    t.string "hp_mso_address_line1"
    t.string "hp_mso_address_line2"
    t.string "hp_city"
    t.string "hp_zipcode"
    t.string "hp_mso_telephone_number"
    t.string "hp_ext"
    t.string "hp_mso_fax_number"
    t.string "hp_mso_email_address"
    t.string "hp_department_name"
    t.string "hp_division_name"
    t.string "director_first_name"
    t.string "director_last_name"
    t.string "unrestricted_privileges"
    t.string "privileges_temporary"
    t.string "privilege_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_source_id"], name: "index_hospital_privileges_on_provider_source_id"
  end

  create_table "hospitals", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hvhs_data", force: :cascade do |t|
    t.string "npi"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "degree_titles"
    t.string "office_address_line1"
    t.string "office_address_line2"
    t.string "office_city"
    t.string "office_state"
    t.string "office_zip_code"
    t.string "phone_number"
    t.string "practice_email_address"
    t.string "office_mgr_email"
    t.string "office_mgr_fax"
    t.string "office_mgr_first_name"
    t.string "office_mgr_last_name"
    t.string "office_mgr_phone"
    t.string "special_type"
    t.string "taxonomy_code"
    t.string "license_number"
    t.string "license_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "languages", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "licensed_members", force: :cascade do |t|
    t.string "licensed_member_first_name"
    t.string "licensed_member_last_name"
    t.string "licensed_member_middle_name"
    t.string "licensed_member_suffix_name"
    t.string "licensed_member_practitioner_type"
    t.string "licensed_member_specialty"
    t.string "licensed_member_is_partner"
    t.string "licensed_member_is_employing_physician"
    t.bigint "practice_information_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["practice_information_id"], name: "index_licensed_members_on_practice_information_id"
  end

  create_table "licensure_webcrawler_logs", force: :cascade do |t|
    t.string "filepath"
    t.string "filetype"
    t.string "status"
    t.bigint "rva_information_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rva_information_id"], name: "index_licensure_webcrawler_logs_on_rva_information_id"
  end

  create_table "method_resolutions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.string "type", null: false
    t.jsonb "params"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["read_at"], name: "index_notifications_on_read_at"
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient"
  end

  create_table "oig_webcrawler_logs", force: :cascade do |t|
    t.string "filepath"
    t.string "filetype"
    t.string "status"
    t.bigint "rva_information_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rva_information_id"], name: "index_oig_webcrawler_logs_on_rva_information_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "verification_product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["verification_product_id"], name: "index_order_items_on_verification_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "client_organization_id", null: false
    t.string "status", default: "pending"
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_cents"
    t.string "payment_method"
    t.string "payment_memo"
    t.index ["client_organization_id"], name: "index_orders_on_client_organization_id"
  end

  create_table "other_names", force: :cascade do |t|
    t.bigint "provider_source_id", null: false
    t.string "name_type"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "suffix"
    t.date "date_started"
    t.date "date_stopped"
    t.boolean "in_use"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "temp_key"
    t.index ["provider_source_id", "temp_key"], name: "idx_other_names_on_psid_idx", unique: true
    t.index ["provider_source_id"], name: "index_other_names_on_provider_source_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "stripe_payment_intent_id"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "payment_method"
    t.decimal "amount"
    t.string "solana_signature"
    t.index ["order_id"], name: "index_payments_on_order_id"
  end

  create_table "pdf_generation_queues", force: :cascade do |t|
    t.bigint "provider_personal_information_id", null: false
    t.string "queue_number"
    t.string "status", default: "queued"
    t.datetime "queued_date"
    t.datetime "generated_date"
    t.text "message"
    t.text "selected_links", default: [], array: true
    t.string "pdf_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "deleted"
    t.index ["provider_personal_information_id"], name: "index_pdf_generation_queues_on_provider_personal_information_id"
  end

  create_table "pdf_queue_items", force: :cascade do |t|
    t.bigint "pdf_generation_queue_id", null: false
    t.string "file_name"
    t.string "file_path"
    t.string "status", default: "queued"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "message"
    t.index ["pdf_generation_queue_id"], name: "index_pdf_queue_items_on_pdf_generation_queue_id"
  end

  create_table "personally_employed_practitioners", force: :cascade do |t|
    t.string "personal_employed_first_name"
    t.string "personal_employed_last_name"
    t.string "personal_employed_suffix_name"
    t.string "personal_employed_practitioner_type"
    t.string "personal_employed_state_license_number"
    t.bigint "practice_information_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["practice_information_id"], name: "pep_ppi_id"
  end

  create_table "practice_accessibilities", force: :cascade do |t|
    t.integer "caqh_provider_practice_accessibility_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.boolean "accessibility_flag"
    t.text "other_accessibility_description"
    t.text "accessibility_accessibility_description"
    t.bigint "practice_information_id"
    t.integer "caqh_provider_practice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["practice_information_id"], name: "index_practice_accessibilities_on_practice_information_id"
    t.index ["provider_attest_id"], name: "index_practice_accessibilities_on_provider_attest_id"
  end

  create_table "practice_associate_other_questions", force: :cascade do |t|
    t.integer "caqh_provider_practice_associate_other_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "coverage_availability"
    t.bigint "practice_information_id"
    t.bigint "practice_associate_id"
    t.integer "caqh_provider_practice_id"
    t.integer "caqh_provider_practice_associate_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["practice_associate_id"], name: "paoq_ppa_id"
    t.index ["practice_information_id"], name: "paoq_pp_id"
    t.index ["provider_attest_id"], name: "index_practice_associate_other_questions_on_provider_attest_id"
  end

  create_table "practice_associate_specialties", force: :cascade do |t|
    t.integer "caqh_provider_practice_associate_specialty_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "specialty_specialty_name"
    t.bigint "practice_information_id"
    t.bigint "practice_associate_id"
    t.integer "caqh_provider_practice_id"
    t.integer "caqh_provider_practice_associate_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["practice_associate_id"], name: "index_practice_associate_specialties_on_practice_associate_id"
    t.index ["practice_information_id"], name: "index_practice_associate_specialties_on_practice_information_id"
    t.index ["provider_attest_id"], name: "index_practice_associate_specialties_on_provider_attest_id"
  end

  create_table "practice_associates", force: :cascade do |t|
    t.integer "caqh_provider_practice_associate_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "associate_first_name"
    t.string "associate_last_name"
    t.string "associate_middle_initial"
    t.string "address"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "county"
    t.string "phone_number"
    t.string "fax_number"
    t.string "email_address"
    t.string "license_number"
    t.string "license_state"
    t.string "hospital_department_name"
    t.string "check_payable_to"
    t.boolean "electronic_billing_flag"
    t.boolean "coverage_flag"
    t.string "billing_company"
    t.string "coverage_arrangement_explanation"
    t.string "tax_id"
    t.string "other_skills"
    t.string "emergency_phone_number"
    t.string "answering_service_phone_number"
    t.string "title"
    t.string "tax_id_name"
    t.string "phone_extension"
    t.string "degree_degree_abbreviation"
    t.string "provider_type_provider_type_abbreviation"
    t.string "associate_type_associate_type_description"
    t.bigint "practice_information_id"
    t.integer "caqh_provider_practice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["practice_information_id"], name: "index_practice_associates_on_practice_information_id"
    t.index ["provider_attest_id"], name: "index_practice_associates_on_provider_attest_id"
  end

  create_table "practice_business_arrangements", force: :cascade do |t|
    t.integer "caqh_provider_practice_business_arrangement_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "business_arrangement_name"
    t.string "business_arrangement_type"
    t.string "tax_id"
    t.string "address"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "phone_number"
    t.string "country_country_name"
    t.bigint "practice_information_id"
    t.integer "caqh_provider_practice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["practice_information_id"], name: "index_practice_business_arrangements_on_practice_information_id"
    t.index ["provider_attest_id"], name: "index_practice_business_arrangements_on_provider_attest_id"
  end

  create_table "practice_certifications", force: :cascade do |t|
    t.integer "caqh_provider_practice_certification_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.boolean "certification_flag"
    t.datetime "expiration_date"
    t.text "other_certification_explanation"
    t.boolean "staff_certified_flag"
    t.boolean "provider_certified_flag"
    t.text "certification_description"
    t.datetime "certification_date"
    t.bigint "practice_information_id"
    t.integer "caqh_provider_practice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["practice_information_id"], name: "index_practice_certifications_on_practice_information_id"
    t.index ["provider_attest_id"], name: "index_practice_certifications_on_provider_attest_id"
  end

  create_table "practice_hours", force: :cascade do |t|
    t.integer "caqh_provider_practice_hours_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.boolean "no_office_hours_flag"
    t.string "morning_hours"
    t.string "afternoon_hours"
    t.string "evening_hours"
    t.string "office_hours"
    t.string "evening_weekend_hours"
    t.boolean "evening_hours_flag"
    t.boolean "weekend_hours_flag"
    t.string "start_hours_hours"
    t.text "hours_type_hours_type_description"
    t.string "end_hours_hours"
    t.string "day_of_week_day_of_week_name"
    t.bigint "practice_information_id"
    t.integer "caqh_provider_practice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["practice_information_id"], name: "index_practice_hours_on_practice_information_id"
    t.index ["provider_attest_id"], name: "index_practice_hours_on_provider_attest_id"
  end

  create_table "practice_information_educations", force: :cascade do |t|
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "institution_name"
    t.string "address"
    t.string "address2"
    t.string "city"
    t.string "county"
    t.string "province"
    t.string "postal_code"
    t.string "country"
    t.string "state"
    t.string "phone_number"
    t.string "email_address"
    t.string "fax_number"
    t.string "program_title"
    t.string "degree_degree_abbreviation"
    t.string "incomplete_explanation"
    t.boolean "program_completed_flag"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "suite_dept_mail_stop"
    t.string "if_other_list"
    t.text "comments"
    t.boolean "show_on_tickler", default: false
    t.string "verification_status"
    t.integer "caqh_practice_information_education_id"
    t.index ["provider_attest_id"], name: "index_practice_information_educations_on_provider_attest_id"
  end

  create_table "practice_informations", force: :cascade do |t|
    t.integer "caqh_provider_practice_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "practice_name"
    t.string "address"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "ext_zip"
    t.string "county"
    t.string "phone_number"
    t.string "after_hours_phone_number"
    t.string "fax_number"
    t.string "email_address"
    t.boolean "correspondence_flag"
    t.boolean "partners_flag"
    t.boolean "other_associates_flag"
    t.boolean "currently_practicing_flag"
    t.datetime "start_date"
    t.boolean "coverage24x7_flag"
    t.boolean "practice_limitation_flag"
    t.boolean "ada_approved_flag"
    t.boolean "minority_business_flag"
    t.boolean "interpreter_available_flag"
    t.string "medicare_number"
    t.string "medicaid_number"
    t.boolean "epsdt_certified_flag"
    t.string "epsdt_number"
    t.string "practice_organization_type"
    t.string "phone_number2"
    t.string "patient_appointment_phone_number"
    t.string "answering_service_phone_number"
    t.string "pager_beeper_number"
    t.boolean "list_in_directory_flag"
    t.string "w9_practice_name"
    t.boolean "in_practice_flag"
    t.text "practice_intention_explanation"
    t.string "emergency_phone_number"
    t.text "practice_description"
    t.string "patients_enrolled"
    t.string "patient_visits"
    t.string "appointments_per_hour"
    t.string "average_waiting_time"
    t.string "call_response_time"
    t.boolean "electronic_billing_flag"
    t.string "bwc_number"
    t.string "workers_compensation_risk_number"
    t.text "ownership_description"
    t.string "emergency_procedure"
    t.string "npi"
    t.text "practice_type_description"
    t.text "service_type_description"
    t.string "department_name"
    t.string "cell_phone_number"
    t.string "pager_beeper_number2"
    t.datetime "end_date"
    t.string "phone_extension"
    t.string "patient_appointment_phone_extension"
    t.string "answering_service_phone_extension"
    t.string "correspondence_method"
    t.text "address_type_address_type_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "country"
    t.string "office_manager"
    t.string "manager_phone_number"
    t.string "manager_fax_number"
    t.string "back_office_phone_number"
    t.string "type_of_practice"
    t.string "mail_stop"
    t.string "hospital_based_department_name"
    t.string "practice_type"
    t.string "group_name"
    t.string "group_number_with_tax_id"
    t.string "name_affiliated_with_tax_id"
    t.string "federal_tax_id"
    t.string "number_of_patients_weekly"
    t.string "total_number_of_patients"
    t.string "total_medicare_patients"
    t.string "total_medical_medicaid_patients"
    t.boolean "is_ccs", default: false
    t.boolean "is_chdp", default: false
    t.boolean "any_allied_health_practitioner", default: false
    t.integer "physician_to_nurse_ratio"
    t.integer "physician_to_midwife_ratio"
    t.integer "physician_to_assistant_ratio"
    t.boolean "is_employing_any_personal_practitioner", default: false
    t.boolean "is_licensed_member_in_practice", default: false
    t.boolean "is_staff_speak_any_foreign_language", default: false
    t.boolean "radiology_services", default: false
    t.boolean "allergy_injections", default: false
    t.boolean "age_approriate_immunizations", default: false
    t.boolean "osteopathic_manipulations", default: false
    t.boolean "ekg", default: false
    t.boolean "allergy_skin_tests", default: false
    t.boolean "flexible_sigmoidoscopy", default: false
    t.boolean "iv_hydration_treatments", default: false
    t.boolean "care_of_minor_lacerations", default: false
    t.boolean "routine_office_gynecology", default: false
    t.boolean "tympanometry_audiometry_tests", default: false
    t.boolean "cardiac_stress_tests", default: false
    t.boolean "pulmonary_function_tests", default: false
    t.boolean "drawing_blood", default: false
    t.boolean "asthma_treatmeant", default: false
    t.boolean "physical_therapies", default: false
    t.string "other_surgical_services"
    t.string "clinical_services_performed_not_typically_associated"
    t.string "clinical_services_not_performed_typically_associated"
    t.boolean "has_practice_limit_age", default: false
    t.string "practice_limit_age_from"
    t.string "practice_limit_age_to"
    t.boolean "has_limited_gender", default: false
    t.string "limited_gender"
    t.string "other_limitations"
    t.string "computer_office"
    t.boolean "computer_office_has_other", default: false
    t.string "computer_office_other"
    t.string "operating_system"
    t.boolean "has_os_office_other", default: false
    t.string "os_office_other"
    t.boolean "has_computer_has_internet_access", default: false
    t.boolean "does_participate_edi", default: false
    t.string "edi_network"
    t.boolean "has_practice_management_software", default: false
    t.string "practice_management_software"
    t.boolean "does_perform_surgery", default: false
    t.boolean "anesthesia_local", default: false
    t.boolean "anesthesia_regional", default: false
    t.boolean "anesthesia_conscious_sedation", default: false
    t.boolean "anesthesia_general", default: false
    t.boolean "anesthesia_other", default: false
    t.string "anesthesia_other_value"
    t.boolean "anesthesia_none", default: false
    t.boolean "ambulatory_surgery_facilities", default: false
    t.boolean "health_surgery_licensure", default: false
    t.boolean "ambulatory_health_care", default: false
    t.boolean "medicare_certification", default: false
    t.boolean "medical_quality_commission", default: false
    t.boolean "other_certification", default: false
    t.text "other_certification_explanation"
    t.boolean "certification_none", default: false
    t.boolean "is_laboratory_services", default: false
    t.string "billing_name"
    t.string "tax_id"
    t.string "type_of_service"
    t.boolean "clia_waiver", default: false
    t.boolean "clia_certificate", default: false
    t.integer "clia_certificate_number"
    t.date "clia_certificate_expiration_date"
    t.string "clia_certification_of_participation"
    t.string "other_clia"
    t.string "xray_certification_type"
    t.boolean "coverage_24_hour", default: false
    t.boolean "answering_service", default: false
    t.boolean "voice_mail_with_instruction", default: false
    t.boolean "voice_mail_with_other_instruction", default: false
    t.string "answering_service_company"
    t.string "answering_service_fax_number"
    t.string "answering_service_mail_address"
    t.string "answering_service_mail_stop"
    t.string "answering_service_address2"
    t.string "answering_service_city"
    t.string "answering_service_country"
    t.string "answering_service_state"
    t.string "answering_service_zipcode"
    t.boolean "any_cover_practitioner", default: false
    t.boolean "ada_accessibility", default: false
    t.boolean "handicapped_building", default: false
    t.boolean "handicapped_parking", default: false
    t.boolean "handicapped_restroom", default: false
    t.boolean "handicapped_other", default: false
    t.string "handicapped_other_explaination"
    t.boolean "disabled_telephony", default: false
    t.boolean "american_sign_language", default: false
    t.boolean "disabled_impairment_services", default: false
    t.boolean "disabled_other", default: false
    t.string "disabled_other_explaination"
    t.boolean "other_communication_system", default: false
    t.boolean "public_transportation", default: false
    t.boolean "public_bus", default: false
    t.boolean "public_subway", default: false
    t.boolean "public_regional_train", default: false
    t.boolean "public_other_transportation", default: false
    t.string "public_other_transportation_explaination"
    t.boolean "is_provide_child_care_service", default: false
    t.boolean "is_tdd", default: false
    t.boolean "is_epsdt_certified", default: false
    t.integer "epsdt_certificate_number"
    t.boolean "is_directory_location_listed", default: false
    t.boolean "is_minority_business_enterprise", default: false
    t.integer "group_npi"
    t.boolean "is_primary_location", default: false
    t.text "any_comments"
    t.time "mon_time_from"
    t.time "mon_time_to"
    t.boolean "mon_closed", default: false
    t.time "tue_time_from"
    t.time "tue_time_to"
    t.boolean "tue_closed", default: false
    t.time "wed_time_from"
    t.time "wed_time_to"
    t.boolean "wed_closed", default: false
    t.time "thu_time_from"
    t.time "thu_time_to"
    t.boolean "thu_closed", default: false
    t.time "fri_time_from"
    t.time "fri_time_to"
    t.boolean "fri_closed", default: false
    t.time "sat_time_from"
    t.time "sat_time_to"
    t.boolean "sat_closed", default: false
    t.time "sun_time_from"
    t.time "sun_time_to"
    t.boolean "sun_closed", default: false
    t.time "holiday_time_from"
    t.time "holiday_time_to"
    t.boolean "holiday_closed", default: false
    t.string "provider_type"
    t.string "cred_cycle"
    t.date "birth_date"
    t.string "ssn"
    t.string "provider_status"
    t.date "attestation_date"
    t.date "file_due_date"
    t.date "app_complete_date"
    t.boolean "app_reviewed"
    t.text "batch_description"
    t.text "comment"
    t.index ["provider_attest_id"], name: "index_practice_informations_on_provider_attest_id"
  end

  create_table "practice_languages", force: :cascade do |t|
    t.integer "caqh_provider_practice_language_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "language_type"
    t.string "linguist_name"
    t.string "language_language_name"
    t.text "employee_type_employee_type_description"
    t.bigint "practice_information_id"
    t.integer "caqh_provider_practice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["practice_information_id"], name: "index_practice_languages_on_practice_information_id"
    t.index ["provider_attest_id"], name: "index_practice_languages_on_provider_attest_id"
  end

  create_table "practice_limitations", force: :cascade do |t|
    t.integer "caqh_provider_practice_limitation_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.boolean "age_limitation_flag"
    t.integer "age_limitation_minimum"
    t.integer "age_limitation_maximum"
    t.text "other_limitation_description"
    t.boolean "specialty_limitation_flag"
    t.text "specialty_limitation_description"
    t.text "gender_limitation_gender_limitation_description"
    t.bigint "practice_information_id"
    t.integer "caqh_provider_practice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["practice_information_id"], name: "index_practice_limitations_on_practice_information_id"
    t.index ["provider_attest_id"], name: "index_practice_limitations_on_provider_attest_id"
  end

  create_table "practice_locations", force: :cascade do |t|
    t.string "location"
    t.string "legal_name"
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "state_id"
    t.string "zip_code"
    t.string "phone_number"
    t.string "fax_number"
    t.string "email"
    t.string "group_tax_number"
    t.string "group_npi_number"
    t.boolean "have_group_tax_number"
    t.datetime "group_npi_number_effective_date"
    t.string "languages_speak"
    t.string "languages_write"
    t.string "interpreters_available"
    t.string "contact_first_name"
    t.string "contact_middle_name"
    t.string "contact_last_name"
    t.string "contact_suffix"
    t.string "contact_title"
    t.string "contact_phone_number"
    t.string "contact_ext"
    t.string "contact_fax_number"
    t.string "contact_email"
    t.time "monday_time_start"
    t.time "monday_time_end"
    t.boolean "monday_split_day"
    t.boolean "monday_closed"
    t.time "tuesday_time_start"
    t.time "tuesday_time_end"
    t.boolean "tuesday_split_day"
    t.boolean "tuesday_closed"
    t.time "wednesday_time_start"
    t.time "wednesday_time_end"
    t.boolean "wednesday_split_day"
    t.boolean "wednesday_closed"
    t.time "thursday_time_start"
    t.time "thursday_time_end"
    t.boolean "thursday_split_day"
    t.boolean "thursday_closed"
    t.time "friday_time_start"
    t.time "friday_time_end"
    t.boolean "friday_split_day"
    t.boolean "friday_closed"
    t.time "saturday_time_start"
    t.time "saturday_time_end"
    t.boolean "saturday_split_day"
    t.boolean "saturday_closed"
    t.time "sunday_time_start"
    t.time "sunday_time_end"
    t.boolean "sunday_split_day"
    t.boolean "sunday_closed"
    t.string "comment"
    t.string "telephone_coverage"
    t.string "telephone_coverage_type"
    t.string "telephone_number_after_hours"
    t.string "telephone_number_ext"
    t.string "pa_practice_status"
    t.string "pa_by_health_plan"
    t.string "pa_limitations"
    t.string "pa_gender_limitations"
    t.integer "pa_minimum_age"
    t.integer "pa_maximum_age"
    t.boolean "pa_min_max_not_applicable"
    t.string "pa_other_limitations"
    t.string "ada_accessibility"
    t.string "ada_wrp"
    t.string "disabled_other_services"
    t.string "disabled_other_services_wrp"
    t.string "public_transportation"
    t.string "public_transportation_wrp"
    t.string "laboratory_services"
    t.string "laboratory_services_wrp"
    t.string "clia_waiver"
    t.string "clia_waiver_wrp"
    t.string "clia_waiver_expiration_date"
    t.string "clia_certificate"
    t.string "clia_certificate_wrp"
    t.string "clia_certificate_expiration_date"
    t.string "radiology_services"
    t.string "radiology_services_xray"
    t.string "radiology_services_fda"
    t.string "anesthesia_administered"
    t.string "additional_procedures"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "open_practice_status", default: [], array: true
    t.string "ada_wrp_status", default: [], array: true
    t.string "disabled_other_services_wrp_status", default: [], array: true
    t.string "public_transportation_wrp_status", default: [], array: true
    t.string "laboratory_services_wrp_status", default: [], array: true
    t.string "radiology_services_xray_status", default: [], array: true
    t.string "anesthesia_administered_status", default: [], array: true
    t.time "monday_time_start_2"
    t.time "monday_time_end_2"
    t.time "tuesday_time_start_2"
    t.time "tuesday_time_end_2"
    t.time "wednesday_time_start_2"
    t.time "wednesday_time_end_2"
    t.time "thursday_time_start_2"
    t.time "thursday_time_end_2"
    t.time "friday_time_start_2"
    t.time "friday_time_end_2"
    t.time "saturday_time_start_2"
    t.time "saturday_time_end_2"
    t.time "sunday_time_start_2"
    t.time "sunday_time_end_2"
    t.bigint "practice_information_id"
    t.index ["practice_information_id"], name: "index_practice_locations_on_practice_information_id"
  end

  create_table "practice_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "practitioner_profiles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "practitioners", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "suffix"
    t.string "gender"
    t.date "date_of_birth"
    t.string "social_security_number"
    t.string "contact_method"
    t.string "phone_number"
    t.string "fax_number"
    t.string "email_address"
    t.string "address"
    t.string "suit_or_apt"
    t.string "additional_address"
    t.string "city"
    t.string "country"
    t.string "state_or_province"
    t.string "zipcode"
    t.string "practitioner_type"
    t.date "credentials_committee_date"
    t.string "client_batch_name"
    t.string "client_batch_id"
    t.string "market"
    t.string "status"
    t.string "application_method"
    t.string "availability"
    t.string "county"
  end

  create_table "privilege_statuses", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "professional_organizations", force: :cascade do |t|
    t.string "prof_organization_name", null: false
    t.date "prof_org_effected_date", null: false
    t.date "prof_org_termination_date", null: false
    t.boolean "prof_org_until_current", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "caqh_provider_professional_organization_id"
    t.integer "caqh_provider_attest_id"
    t.bigint "provider_attest_id"
    t.index ["provider_attest_id"], name: "index_professional_organizations_on_provider_attest_id"
  end

  create_table "provider_adverse_actions", force: :cascade do |t|
    t.integer "caqh_provider_adverse_action_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.datetime "occurrence_date"
    t.text "occurrence_explanation"
    t.datetime "action_date"
    t.text "action_explanation"
    t.string "current_status"
    t.string "contact_name"
    t.string "department_name"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "phone_number"
    t.string "postal_code"
    t.string "location"
    t.string "organization_name"
    t.datetime "end_date"
    t.text "disclosure_question_disclosure_summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_adverse_actions_on_provider_attest_id"
  end

  create_table "provider_anesthesia_administrations", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "suffix"
    t.string "practitioner_type"
    t.text "other_explaination"
    t.boolean "is_class_a", default: false
    t.boolean "is_class_b", default: false
    t.boolean "is_class_c", default: false
    t.bigint "practice_information_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["practice_information_id"], name: "paa_ppi_id"
  end

  create_table "provider_associates", force: :cascade do |t|
    t.integer "caqh_provider_associate_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "associate_first_name"
    t.string "associate_last_name"
    t.string "associate_middle_initial"
    t.string "associate_name"
    t.string "address"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "province"
    t.string "phone_number"
    t.string "phone_extension"
    t.string "fax_number"
    t.string "email_address"
    t.string "title"
    t.string "country_country_name"
    t.string "specialty_specialty_name"
    t.string "degree_degree_abbreviation"
    t.text "associate_type_associate_type_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_associates_on_provider_attest_id"
  end

  create_table "provider_attests", force: :cascade do |t|
    t.integer "caqh_provider_attest_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "provider_board_certifications", force: :cascade do |t|
    t.bigint "provider_id"
    t.string "bc_board_certification"
    t.string "bc_board_name"
    t.string "bc_certification_number"
    t.string "bc_specialty_type"
    t.datetime "bc_effective_date"
    t.datetime "bc_expiration_date"
    t.datetime "bc_recertification_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_board_certifications_on_provider_id"
  end

  create_table "provider_cds", force: :cascade do |t|
    t.integer "caqh_provider_cdsid"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "cds_number"
    t.string "state"
    t.datetime "expiration_date"
    t.datetime "issue_date"
    t.boolean "currently_practicing_flag"
    t.text "cds_limitation_explanation"
    t.string "cds_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "show_on_tickler"
    t.index ["provider_attest_id"], name: "index_provider_cds_on_provider_attest_id"
  end

  create_table "provider_cds_licenses", force: :cascade do |t|
    t.bigint "provider_id"
    t.string "cds_license_number"
    t.string "no_cds_license"
    t.integer "state_id"
    t.datetime "cds_license_issue_date"
    t.datetime "cds_license_expiration_date"
    t.datetime "cds_renewal_effective_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_cds_licenses_on_provider_id"
  end

  create_table "provider_cnp_licenses", force: :cascade do |t|
    t.bigint "provider_id"
    t.string "cnp_license_number"
    t.datetime "effective_date"
    t.datetime "expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "cnp_license_renewal_effective_date"
    t.string "no_cnp_license"
    t.integer "state_id"
    t.index ["provider_id"], name: "index_provider_cnp_licenses_on_provider_id"
  end

  create_table "provider_dea_licenses", force: :cascade do |t|
    t.bigint "provider_id"
    t.string "dea_license_number"
    t.integer "state_id"
    t.datetime "dea_license_effective_date"
    t.datetime "dea_license_expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "dea_license_renewal_effective_date"
    t.string "no_dea_license"
    t.index ["provider_id"], name: "index_provider_dea_licenses_on_provider_id"
  end


  create_table "provider_deas", force: :cascade do |t|
    t.integer "caqh_provider_deaid"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "dea_number"
    t.string "state"
    t.datetime "expiration_date"
    t.boolean "dea_license_limitation_flag"
    t.text "dea_license_limitation_explanation"
    t.text "no_dea_explanation"
    t.datetime "application_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "show_on_tickler"
    t.string "full_schedule"
    t.string "schedules_held"
    t.index ["provider_attest_id"], name: "index_provider_deas_on_provider_attest_id"
  end

  create_table "provider_degrees", force: :cascade do |t|
    t.integer "caqh_provider_degree_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "degree_degree_abbreviation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_degrees_on_provider_attest_id"
  end

  create_table "provider_deleted_document_logs", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.string "document_key"
    t.string "title"
    t.string "note"
    t.string "deleted_by"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_deleted_document_logs_on_provider_id"
  end


  create_table "provider_disclosures", force: :cascade do |t|
    t.integer "caqh_provider_disclosure_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.boolean "disclosure_answer_flag"
    t.datetime "disclosure_date"
    t.text "disclosure_explanation"
    t.text "disclosure_question_disclosure_summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_disclosures_on_provider_attest_id"
  end

  create_table "provider_education_associates", force: :cascade do |t|
    t.integer "caqh_provider_education_associate_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.bigint "provider_education_id"
    t.integer "caqh_provider_education_id"
    t.string "associate_first_name"
    t.string "associate_last_name"
    t.string "associate_middle_initial"
    t.string "title"
    t.string "address"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "province"
    t.string "postal_code"
    t.string "phone_number"
    t.string "phone_extension"
    t.string "fax_number"
    t.string "email_address"
    t.string "country_country_name"
    t.text "associate_type_associate_type_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_education_associates_on_provider_attest_id"
    t.index ["provider_education_id"], name: "index_provider_education_associates_on_provider_education_id"
  end

  create_table "provider_educations", force: :cascade do |t|
    t.integer "caqh_provider_education_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "institution_name"
    t.string "address"
    t.string "address2"
    t.string "city"
    t.string "province"
    t.string "state"
    t.string "postal_code"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "affiliated_university_name"
    t.string "hospital_department_name"
    t.string "training_area"
    t.string "email_address"
    t.string "certificate_issued_by"
    t.string "program_title"
    t.boolean "apa_approved_flag"
    t.boolean "program_completed_flag"
    t.string "program_director"
    t.datetime "completion_date"
    t.string "certificate_awarded"
    t.string "teaching_position"
    t.string "current_program_director"
    t.text "incomplete_explanation"
    t.string "phone_number"
    t.string "fax_number"
    t.boolean "disciplinary_action_flag"
    t.text "disciplinary_action_explanation"
    t.string "program_director_degree"
    t.string "program_type"
    t.text "additional_training_description"
    t.string "education_type_name"
    t.string "hours"
    t.string "country_country_name"
    t.string "degree_degree_abbreviation"
    t.string "specialty_specialty_name"
    t.text "institution_type_institution_type_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "suite"
    t.string "country"
    t.string "county"
    t.boolean "current_program_director_flag"
    t.string "contact"
    t.text "comments"
    t.boolean "show_on_tickler", default: false
    t.string "audit_status"
    t.index ["provider_attest_id"], name: "index_provider_educations_on_provider_attest_id"
  end

  create_table "provider_employments", force: :cascade do |t|
    t.bigint "provider_attest_id", null: false
    t.string "employer_name"
    t.string "title"
    t.string "contact_first_name"
    t.string "contact_middle_name"
    t.string "contact_last_name"
    t.string "contact_suffix"
    t.string "practitioner_type"
    t.string "address"
    t.string "mail_stop"
    t.string "additional_address"
    t.string "city"
    t.string "county"
    t.string "state"
    t.string "country"
    t.string "zip"
    t.string "phone_number"
    t.string "fax"
    t.string "email"
    t.string "work_status"
    t.string "population_serviced"
    t.string "contact_method"
    t.date "from_date"
    t.date "to_date"
    t.string "position"
    t.boolean "show_on_tickler"
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "audit_status"
    t.integer "caqh_provider_employment_id"
    t.index ["provider_attest_id"], name: "index_provider_employments_on_provider_attest_id"
  end

  create_table "provider_hospital_associates", force: :cascade do |t|
    t.integer "caqh_provider_hospital_associate_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "associate_first_name"
    t.string "associate_last_name"
    t.string "associate_middle_initial"
    t.string "address"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "county"
    t.string "postal_code"
    t.string "phone_number"
    t.string "fax_number"
    t.string "email_address"
    t.text "associate_type_associate_type_description"
    t.bigint "provider_hospital_privilege_id"
    t.integer "caqh_provider_hospital_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_hospital_associates_on_provider_attest_id"
  end

  create_table "provider_hospital_privileges", force: :cascade do |t|
    t.integer "caqh_provider_hospital_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.integer "aha_hospital_id"
    t.string "hospital_name"
    t.string "address"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "phone_number"
    t.boolean "unrestricted_privileges_flag"
    t.text "privilege_description"
    t.boolean "temporary_privileges_flag"
    t.integer "admission_percent"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "staff_category"
    t.text "privilege_restriction_explanation"
    t.boolean "application_date"
    t.text "no_privileges_explanation"
    t.string "fax_number"
    t.string "email_address"
    t.text "exit_explanation"
    t.boolean "admit_inpatient_flag"
    t.string "contact_name"
    t.string "province"
    t.string "department_telephone_number"
    t.string "medical_staff_fax_number"
    t.string "department_name"
    t.text "specialty_limitation_explanation"
    t.string "website"
    t.text "coverage_arrangement_explanation"
    t.integer "admits_per_month"
    t.text "hospital_affiliation_type_hospital_affiliation_type_description"
    t.string "country_country_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_hospital_privileges_on_provider_attest_id"
  end

  create_table "provider_identification_numbers", force: :cascade do |t|
    t.integer "caqh_provider_identifier_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "identifier_value"
    t.string "identifier_status"
    t.boolean "identifier_flag"
    t.string "state"
    t.datetime "issue_date"
    t.datetime "expiration_date"
    t.string "sponsor"
    t.string "country_country_name"
    t.text "identifier_type_identifier_type_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_identification_numbers_on_provider_attest_id"
  end

  create_table "provider_ins_policies", force: :cascade do |t|
    t.bigint "provider_id"
    t.string "ins_policy_number"
    t.datetime "effective_date"
    t.datetime "expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_ins_policies_on_provider_id"
  end


  create_table "provider_insurance_coverages", force: :cascade do |t|
    t.integer "caqh_provider_insurance_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "insurance_carrier_name"
    t.datetime "original_start_date"
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean "self_insured_flag"
    t.string "address"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "province"
    t.string "postal_code"
    t.string "phone_number"
    t.string "policy_number"
    t.boolean "individual_coverage_flag"
    t.string "coverage_amount_occurrence"
    t.string "coverage_amount_aggregate"
    t.string "agent_last_name"
    t.string "agent_first_name"
    t.string "policy_holder"
    t.boolean "no_malpractice_claims_flag"
    t.datetime "retroactive_date"
    t.boolean "tail_nose_coverage_flag"
    t.text "tail_nose_coverage_explanation"
    t.string "time_with_carrier"
    t.boolean "coverage_limit_exceeded_flag"
    t.boolean "unlimited_coverage_flag"
    t.string "fax_number"
    t.string "website"
    t.boolean "renewal_date"
    t.string "agent_address"
    t.string "agent_address2"
    t.string "agent_city"
    t.string "agent_state"
    t.string "agent_postal_code"
    t.string "agent_province"
    t.text "surcharge_explanation"
    t.string "excess_coverage_amount"
    t.string "phone_extension"
    t.string "underwriter_name"
    t.string "affiliated_organization_name"
    t.string "agent_country_country_name"
    t.string "country_country_name"
    t.text "insurance_type_insurance_type_description"
    t.text "insurance_coverage_type_insurance_coverage_type_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type_of_policy"
    t.string "additional_address"
    t.string "email_address"
    t.date "effective_date"
    t.integer "claim_amount"
    t.integer "umbrella_coverage_amount"
    t.boolean "tail_coverage"
    t.boolean "current_carrier_excluded"
    t.string "current_carrier_excluded_explanation"
    t.boolean "show_on_tickler"
    t.text "comment"
    t.boolean "liability_not_applicable"
    t.text "liability_explanation"
    t.string "audit_status"
    t.string "claims_history_audit"
    t.index ["provider_attest_id"], name: "index_provider_insurance_coverages_on_provider_attest_id"
  end

  create_table "provider_languages", force: :cascade do |t|
    t.integer "caqh_provider_language_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "language_type"
    t.string "language_language_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_languages_on_provider_attest_id"
  end

  create_table "provider_liability_actions", force: :cascade do |t|
    t.integer "caqh_provider_liability_action_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "insurance_history"
    t.string "carrier_name"
    t.string "policy_number"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "phone_number"
    t.datetime "start_date"
    t.datetime "end_date"
    t.text "circumstances_description"
    t.text "disclosure_question_disclosure_summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_liability_actions_on_provider_attest_id"
  end

  create_table "provider_licenses", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.string "license_number"
    t.date "license_effective_date"
    t.date "license_expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "state_id"
    t.string "license_state_renewal_date"
    t.string "no_state_license"
    t.string "license_type"
    t.index ["provider_id"], name: "index_provider_licenses_on_provider_id"
  end


  create_table "provider_licensures", force: :cascade do |t|
    t.integer "state_id"
    t.string "license_type"
    t.string "license_number"
    t.date "license_issue_date"
    t.date "license_expiration_date"
    t.bigint "provider_attest_id", null: false
    t.integer "caqh_provider_attest_id"
    t.boolean "currently_practice_under_this"
    t.boolean "is_primary_license"
    t.boolean "level_require_supervision"
    t.boolean "failed_state_license_exam"
    t.string "license_person_type"
    t.text "license_comment"
    t.boolean "show_on_tickler"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "audit_status"
    t.index ["provider_attest_id"], name: "index_provider_licensures_on_provider_attest_id"
  end

  create_table "provider_malpractice_case_statuses", force: :cascade do |t|
    t.integer "caqh_provider_malpractice_claim_status_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "claim_status"
    t.float "settlement_amount"
    t.float "settlement_amount_paid"
    t.string "defense_attorney"
    t.datetime "status_date"
    t.float "sought_amount"
    t.float "total_amount"
    t.string "defense_attorney_phone_number"
    t.string "defense_attorney_address"
    t.string "defense_attorney_address2"
    t.string "defense_attorney_city"
    t.string "defense_attorney_state"
    t.string "defense_attorney_postal_code"
    t.string "defense_attorney_province"
    t.string "defense_attorney_county"
    t.string "defense_attorney_country_country_name"
    t.bigint "provider_malpractice_history_id"
    t.integer "caqh_provider_malpractice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_malpractice_case_statuses_on_provider_attest_id"
    t.index ["provider_malpractice_history_id"], name: "pmcs_pm_id"
  end

  create_table "provider_malpractice_histories", force: :cascade do |t|
    t.integer "caqh_provider_malpractice_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "insurance_carrier_name"
    t.datetime "occurrence_date"
    t.string "claim_date"
    t.string "address"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "phone_number"
    t.string "policy_number"
    t.text "allegation_description"
    t.boolean "primary_defendant_flag"
    t.string "number_other_codefendant"
    t.string "case_involvement"
    t.text "patient_injury_description"
    t.boolean "npdb_case_flag"
    t.boolean "court_suit_filed_flag"
    t.datetime "court_date"
    t.string "case_number"
    t.string "case_state"
    t.string "case_county"
    t.string "district"
    t.string "federal_case_number"
    t.string "defendant_name"
    t.string "plaintiff_name"
    t.string "plaintiff_age"
    t.string "other_defendant_names"
    t.string "patient_outcome"
    t.boolean "still_pending_flag"
    t.boolean "still_pending_date"
    t.boolean "trial_date_set_flag"
    t.string "province"
    t.string "provider_status"
    t.string "provider_role"
    t.datetime "case_closed_date"
    t.string "patient_name"
    t.string "patient_age"
    t.string "case_city"
    t.string "incident_location"
    t.boolean "carrier_flag"
    t.string "contact_name"
    t.string "claim_number"
    t.text "other_case_description"
    t.string "court"
    t.string "court_address"
    t.boolean "legal_counsel_flag"
    t.boolean "patient_died_flag"
    t.string "court_address2"
    t.string "court_city"
    t.string "license_number"
    t.string "court_state"
    t.string "court_province"
    t.string "court_zip"
    t.string "country_country_name"
    t.text "disclosure_question_disclosure_summary"
    t.text "patient_gender_gender_description"
    t.string "court_country_country_name"
    t.string "malpractice_resolution_malpractice_resolution_method"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_malpractice_histories_on_provider_attest_id"
  end

  create_table "provider_mccs", force: :cascade do |t|
    t.bigint "provider_id"
    t.string "mcc_username"
    t.string "password"
    t.string "password_digest"
    t.string "mcc_electronic_signature_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_mccs_on_provider_id"
  end

  create_table "provider_medicaids", force: :cascade do |t|
    t.bigint "provider_id"
    t.datetime "effective_date"
    t.datetime "reval_date"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_medicaids_on_provider_id"
  end

  create_table "provider_medicares", force: :cascade do |t|
    t.bigint "provider_id"
    t.string "ptan_number"
    t.datetime "effective_date"
    t.string "medicare_username"
    t.string "password"
    t.string "password_digest"
    t.string "question"
    t.string "answer"
    t.datetime "reval_date"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index ["provider_id"], name: "index_provider_medicares_on_provider_id"
  end

    t.integer "caqh_provider_medicare_id"
    t.integer "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "medicare_number"
    t.string "state"
    t.date "issue_date"
    t.boolean "medicare_opt_in"
    t.boolean "medicare_opt_out"
    t.boolean "medicare_partial"
    t.index ["provider_id"], name: "index_provider_medicares_on_provider_id"
  end

  create_table "provider_militaries", force: :cascade do |t|
    t.integer "caqh_provider_military_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "last_location"
    t.string "discharge_rank"
    t.string "branch"
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean "honorable_discharge_flag"
    t.text "discharge_explanation"
    t.boolean "reserve_guard_flag"
    t.boolean "court_martial_flag"
    t.text "court_martial_explanation"
    t.string "active_duty"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type_of_discharge"
    t.string "reserve_separation_month"
    t.string "reserve_separation_year"
    t.boolean "currently_active_reserve"
    t.string "caqh_id"
    t.string "npi_number"
    t.string "medicare_upin_number"
    t.boolean "tricare_provider"
    t.string "tricare_group_number"
    t.boolean "certified_workers_comp_provider"
    t.string "certificate_number"
    t.boolean "certified_qualified_medical_examiner"
    t.boolean "agreed_medical_examiner"
    t.boolean "us_military_service"
    t.string "branch_of_military"
    t.text "comments"
    t.index ["provider_attest_id"], name: "index_provider_militaries_on_provider_attest_id"
  end

  create_table "provider_mn_licenses", force: :cascade do |t|
    t.bigint "provider_id"
    t.string "mn_license_number"
    t.datetime "mn_license_expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_mn_licenses_on_provider_id"
  end

  create_table "provider_mn_medicaids", force: :cascade do |t|
    t.bigint "provider_id"
    t.string "mn_medicaid_number"
    t.string "mn_medicaid_username"
    t.string "password"
    t.string "password_digest"
    t.string "question"
    t.string "answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_mn_medicaids_on_provider_id"
  end

  create_table "provider_notes", force: :cascade do |t|
    t.bigint "provider_id"
    t.string "title"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_notes_on_provider_id"
  end

  create_table "provider_np_licenses", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.string "np_license_number"
    t.date "np_license_effective_date"
    t.date "np_license_expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "np_license_renewal_effective_date"
    t.string "no_np_license"
    t.integer "state_id"
    t.index ["provider_id"], name: "index_provider_np_licenses_on_provider_id"
  end


  create_table "provider_npdb_comments", force: :cascade do |t|
    t.bigint "provider_npdb_id", null: false
    t.string "subject"
    t.text "message"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_npdb_id"], name: "index_provider_npdb_comments_on_provider_npdb_id"
    t.index ["user_id"], name: "index_provider_npdb_comments_on_user_id"
  end

  create_table "provider_npdbs", force: :cascade do |t|
    t.bigint "provider_attest_id", null: false
    t.integer "caqh_provider_attest_id"
    t.string "practitioner_type"
    t.string "individual_identification_number_1"
    t.string "individual_identification_number_2"
    t.string "individual_identification_number_3"
    t.string "individual_identification_number_4"
    t.boolean "show_on_tickler"
    t.string "status"
    t.string "submit_date"
    t.string "response_date"
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_npdbs_on_provider_attest_id"
  end

  create_table "provider_other_business_interests", force: :cascade do |t|
    t.integer "caqh_provider_other_business_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "organization_name"
    t.string "organization_type"
    t.string "address"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "ext_zip"
    t.string "phone_number"
    t.string "tax_id"
    t.string "percent_owned"
    t.boolean "investment_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_other_business_interests_on_provider_attest_id"
  end

  create_table "provider_other_interests", force: :cascade do |t|
    t.integer "caqh_provider_other_interest_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.text "other_interest_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_other_interests_on_provider_attest_id"
  end

  create_table "provider_other_names", force: :cascade do |t|
    t.integer "caqh_provider_other_name_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "last_name"
    t.string "first_name"
    t.string "middle_name"
    t.string "suffix"
    t.datetime "start_date"
    t.datetime "end_date"
    t.text "other_name_explanation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name_type"
    t.boolean "in_use"
    t.index ["provider_attest_id"], name: "index_provider_other_names_on_provider_attest_id"
  end

  create_table "provider_other_questions", force: :cascade do |t|
    t.integer "caqh_provider_other_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.boolean "provider_answer_flag"
    t.text "provider_answer_text"
    t.datetime "provider_answer_date"
    t.text "other_question_other_question_summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_other_questions_on_provider_attest_id"
  end

  create_table "provider_pa_licenses", force: :cascade do |t|
    t.bigint "provider_id"
    t.string "pa_license_number"
    t.datetime "pa_license_effective_date"
    t.datetime "pa_license_expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "pa_license_renewal_effective_date"
    t.string "no_pa_license"
    t.integer "state_id"
    t.index ["provider_id"], name: "index_provider_pa_licenses_on_provider_id"
  end


  create_table "provider_personal_attempts", force: :cascade do |t|
    t.string "contact_method"
    t.string "attempt_status"
    t.date "contact_date"
    t.text "comments"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.bigint "provider_personal_information_id"
    t.integer "caqh_provider_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_personal_attempts_on_provider_attest_id"
    t.index ["provider_personal_information_id"], name: "ppa_ppi_id"
  end

  create_table "provider_personal_docs_receives", force: :cascade do |t|
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.bigint "provider_personal_information_id"
    t.integer "caqh_provider_id"
    t.date "application_received_date"
    t.date "release_received_date"
    t.date "disclosure_questions_explanation_received_date"
    t.date "face_sheet_received_date"
    t.date "employment_gap_received_date"
    t.date "practice_information_received_date"
    t.date "npdb_findings_explanation_received_date"
    t.date "training_received_date"
    t.date "education_received_date"
    t.date "professional_resource_network_received_date"
    t.date "dea_received_date"
    t.date "pa_sponsor_request_form_received_date"
    t.date "collaborative_agreement_received_date"
    t.boolean "application_received_flag", default: false
    t.boolean "release_received_flag", default: false
    t.boolean "disclosure_questions_explanation_received_flag", default: false
    t.boolean "face_sheet_received_flag", default: false
    t.boolean "employment_gap_received_flag", default: false
    t.boolean "practice_information_received_flag", default: false
    t.boolean "npdb_findings_explanation_received_flag", default: false
    t.boolean "training_received_flag", default: false
    t.boolean "education_received_flag", default: false
    t.boolean "professional_resource_network_received_flag", default: false
    t.boolean "dea_received_flag", default: false
    t.boolean "pa_sponsor_request_form_received_flag", default: false
    t.boolean "collaborative_agreement_received_flag", default: false
    t.boolean "application_received_incomplete_flag", default: false
    t.boolean "release_received_incomplete_flag", default: false
    t.boolean "disclosure_questions_explanation_received_incomplete_flag", default: false
    t.boolean "face_sheet_received_incomplete_flag", default: false
    t.boolean "employment_gap_received_incomplete_flag", default: false
    t.boolean "practice_information_received_incomplete_flag", default: false
    t.boolean "npdb_findings_explanation_received_incomplete_flag", default: false
    t.boolean "training_received_incomplete_flag", default: false
    t.boolean "education_received_incomplete_flag", default: false
    t.boolean "professional_resource_network_received_incomplete_flag", default: false
    t.boolean "dea_received_incomplete_flag", default: false
    t.boolean "pa_sponsor_request_form_received_incomplete_flag", default: false
    t.boolean "collaborative_agreement_received_incomplete_flag", default: false
    t.text "application_comments"
    t.text "release_comments"
    t.text "disclosure_questions_explanation_comments"
    t.text "face_sheet_comments"
    t.text "employment_gap_comments"
    t.text "practice_information_comments"
    t.text "npdb_findings_explanation_comments"
    t.text "training_comments"
    t.text "education_comments"
    t.text "professional_resource_network_comments"
    t.text "dea_comments"
    t.text "pa_sponsor_request_form_comments"
    t.text "collaborative_agreement_comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_personal_docs_receives_on_provider_attest_id"
    t.index ["provider_personal_information_id"], name: "ppdr_ppi_id"
  end

  create_table "provider_personal_docs_uploads", force: :cascade do |t|
    t.string "file_upload"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.bigint "provider_personal_information_id"
    t.integer "caqh_provider_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_personal_docs_uploads_on_provider_attest_id"
    t.index ["provider_personal_information_id"], name: "ppdu_ppi_id"
  end

  create_table "provider_personal_information_app_trackings", force: :cascade do |t|
    t.bigint "provider_personal_information_id", null: false
    t.string "owner"
    t.string "file_status"
    t.string "application_type"
    t.datetime "application_receipt_date"
    t.datetime "application_submitted_date"
    t.datetime "verification_complete_date"
    t.datetime "file_return_to_client_date"
    t.datetime "application_receive_complete_date"
    t.boolean "expedite"
    t.text "application_comment"
    t.text "other_comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "master_issues", default: [], array: true
    t.string "master_reviews", default: [], array: true
    t.index ["provider_personal_information_id"], name: "ppiat_id_ppi_c"
  end

  create_table "provider_personal_information_comments", force: :cascade do |t|
    t.bigint "provider_personal_information_id", null: false
    t.string "subject"
    t.text "message"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_personal_information_id"], name: "ppi_id_ppi_c"
    t.index ["user_id"], name: "index_provider_personal_information_comments_on_user_id"
  end

  create_table "provider_personal_information_confidential_contacts", force: :cascade do |t|
    t.string "contact_method"
    t.string "firstname"
    t.string "middlename"
    t.string "lastname"
    t.string "title"
    t.string "suffix"
    t.string "phone_number"
    t.string "fax"
    t.string "email"
    t.string "address"
    t.string "suite"
    t.string "address2"
    t.string "city"
    t.string "county"
    t.string "state"
    t.string "zip"
    t.string "country"
    t.bigint "provider_personal_information_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_personal_information_id"], name: "ppiccc_ppi_id"
  end

  create_table "provider_personal_information_credentialing_contacts", force: :cascade do |t|
    t.string "contact_method"
    t.string "firstname"
    t.string "middlename"
    t.string "lastname"
    t.string "title"
    t.string "suffix"
    t.string "phone_number"
    t.string "fax"
    t.string "email"
    t.string "address"
    t.string "suite"
    t.string "address2"
    t.string "city"
    t.string "county"
    t.string "state"
    t.string "zip"
    t.string "country"
    t.bigint "provider_personal_information_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "suffix_of_credentialing_contact"
    t.string "fax_number"
    t.string "email_address"
    t.string "suit_or_apt"
    t.string "additional_address"
    t.string "state_or_province"
    t.string "zipcode"
    t.integer "caqh_provider_cred_contact_id"
    t.index ["provider_personal_information_id"], name: "ppicc_ppi_id"
  end

  create_table "provider_personal_information_reinstatements", force: :cascade do |t|
    t.string "state"
    t.string "general"
    t.string "exclusion_type"
    t.string "specialty"
    t.datetime "process_date"
    t.datetime "reinstatement_date"
    t.bigint "provider_personal_information_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_personal_information_id"], name: "ppir_ppi_id"
  end

  create_table "provider_personal_information_sam_records", force: :cascade do |t|
    t.bigint "provider_personal_information_id"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "suffix"
    t.string "ssn"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_primary", default: false
    t.index ["provider_personal_information_id"], name: "ppiid_sam_records"
  end

  create_table "provider_personal_information_sam_rva_records", force: :cascade do |t|
    t.bigint "provider_personal_information_sam_record_id"
    t.string "search_result"
    t.string "exclusion_type"
    t.string "verification_sanctions"
    t.string "comments"
    t.datetime "source_date"
    t.datetime "verification_date"
    t.string "supporting_documentation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_personal_information_sam_record_id"], name: "ppisrr_sam_rva_record_id"
  end

  create_table "provider_personal_informations", force: :cascade do |t|
    t.integer "caqh_provider_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "last_name"
    t.string "first_name"
    t.string "middle_name"
    t.string "suffix"
    t.string "primary_practice_state"
    t.boolean "other_name_flag"
    t.datetime "birth_date"
    t.boolean "us_eligible_flag"
    t.string "ssn"
    t.string "nid"
    t.boolean "dea_flag"
    t.boolean "cds_flag"
    t.string "upin"
    t.boolean "upin_flag"
    t.boolean "npi_flag"
    t.string "npi"
    t.boolean "medicare_provider_flag"
    t.boolean "medicaid_provider_flag"
    t.boolean "other_graduate_education_flag"
    t.boolean "fellowship_training_flag"
    t.boolean "teaching_appointment_flag"
    t.boolean "secondary_specialty_flag"
    t.boolean "other_specialty_flag"
    t.boolean "hospital_privilege_flag"
    t.string "hospital_admitting_arrangements"
    t.boolean "work_history_gap_flag"
    t.boolean "active_military_flag"
    t.string "citizenship_status"
    t.string "visa_number"
    t.string "federal_employee_id"
    t.boolean "no_malpractice_claims_flag"
    t.string "application_type"
    t.boolean "ecfmg_flag"
    t.string "ecfmg_number"
    t.datetime "ecfmg_issue_date"
    t.boolean "hospital_based_flag"
    t.string "email_address"
    t.string "visa_type"
    t.string "visa_status"
    t.string "birth_city"
    t.string "birth_state"
    t.string "tax_id"
    t.string "spouse_last_name"
    t.string "spouse_first_name"
    t.string "other_correspondence_address"
    t.string "emergency_contact_last_name"
    t.string "emergency_contact_first_name"
    t.string "emergency_contact_middle_name"
    t.string "emergency_contact_phone"
    t.string "pager_beeper_number"
    t.string "answering_service_phone_number"
    t.string "cell_phone_number"
    t.boolean "pager_beeper_digital_flag"
    t.datetime "visa_expiration_date"
    t.string "ethnicity_description"
    t.datetime "visa_issue_date"
    t.datetime "ecfmg_expiration_date"
    t.string "work_permit_status"
    t.string "spouse_middle_name"
    t.datetime "state_residence_date"
    t.string "citizenship_country_country_name"
    t.text "marital_status_marital_status_description"
    t.text "gender_gender_description"
    t.string "birth_country_country_name"
    t.text "correspondence_address_type_correspondence_address_type_descrip"
    t.string "provider_type_provider_type_abbreviation"
    t.text "graduate_type_graduate_type_description"
    t.string "nid_country_country_name"
    t.datetime "attest_date"
    t.string "plan_provider_id"
    t.datetime "last_recredential_date"
    t.datetime "next_recredential_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "npi_verification_status"
    t.boolean "show_on_tickler", default: false
    t.string "cred_status"
    t.string "gender"
    t.date "date_of_birth"
    t.string "practitioner_type"
    t.date "credentials_committee_date"
    t.date "client_batch_date"
    t.string "availability"
    t.string "client_batch_name"
    t.integer "client_batch_id"
    t.string "market"
    t.string "status"
    t.string "application_method"
    t.string "verification_status"
    t.string "review_level"
    t.date "recred_due_date"
    t.date "review_date"
    t.string "progress_status"
    t.datetime "committee_date"
    t.string "review_details"
    t.string "cred_cycle"
    t.string "created_by"
    t.string "degree_titles"
    t.string "address_line1"
    t.string "address_line2"
    t.string "city"
    t.string "country"
    t.string "county"
    t.string "fax_number"
    t.string "state"
    t.string "zipcode"
    t.string "telephone_number"
    t.boolean "roster"
    t.datetime "psv_completed_date"
    t.string "hp_health_plans", default: [], array: true
    t.string "hp_hospitals", default: [], array: true
    t.string "hp_directories", default: [], array: true
    t.date "vote_date"
    t.string "vote_by"
    t.index ["provider_attest_id"], name: "index_provider_personal_informations_on_provider_attest_id"
  end

  create_table "provider_personal_uploaded_docs", force: :cascade do |t|
    t.string "image_classification"
    t.string "sub_section"
    t.string "record_item"
    t.text "description"
    t.boolean "exclude_from_profile"
    t.string "file_upload"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.bigint "provider_personal_information_id"
    t.integer "caqh_provider_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_personal_uploaded_docs_on_provider_attest_id"
    t.index ["provider_personal_information_id"], name: "ppud_ppi_id"
  end

  create_table "provider_profiles", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "provider_id"
    t.string "first_name"
    t.string "last_name"
    t.string "npi_number"
    t.string "license_number"
    t.string "state"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "verification_status", default: "pending"
    t.text "failure_reason"
    t.index ["order_id"], name: "index_provider_profiles_on_order_id"
    t.index ["provider_id"], name: "index_provider_profiles_on_provider_id"
  end

  create_table "provider_race_ethnicities", force: :cascade do |t|
    t.integer "caqh_provider_race_ethnicity_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "race_ethnicity_level_1"
    t.string "race_ethnicity_level_2"
    t.string "race_ethnicity_level_3"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_race_ethnicities_on_provider_attest_id"
  end

  create_table "provider_references", force: :cascade do |t|
    t.integer "caqh_provider_reference_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "first_name"
    t.string "last_name"
    t.string "address"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "province"
    t.string "postal_code"
    t.string "phone_number"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "title"
    t.string "fax_number"
    t.string "relationship"
    t.string "years_known"
    t.string "middle_name"
    t.string "employer_name"
    t.string "email_address"
    t.string "cell_phone_number"
    t.string "phone_extension"
    t.string "phone_number2"
    t.string "phone_number2_extension"
    t.string "department"
    t.string "country_country_name"
    t.string "specialty_specialty_name"
    t.string "reference_type_provider_type_abbreviation"
    t.string "degree_degree_abbreviation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_references_on_provider_attest_id"
  end

  create_table "provider_rn_licenses", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.string "rn_license_number"
    t.date "rn_license_effective_date"
    t.date "rn_license_expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "rn_license_renewal_effective_date"
    t.string "no_rn_license"
    t.integer "state_id"
    t.index ["provider_id"], name: "index_provider_rn_licenses_on_provider_id"
  end

  create_table "provider_source_cmes", force: :cascade do |t|
    t.bigint "provider_source_id"
    t.string "training"
    t.string "month_attended"
    t.string "year_attended"
    t.string "hours"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_source_id"], name: "index_provider_source_cmes_on_provider_source_id"
  end

  create_table "provider_source_data", force: :cascade do |t|
    t.bigint "provider_source_id", null: false
    t.string "data_key"
    t.string "data_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_source_id"], name: "index_provider_source_data_on_provider_source_id"
  end

  create_table "provider_source_documents", force: :cascade do |t|
    t.bigint "provider_source_id", null: false
    t.string "file_name"
    t.string "file_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_source_id"], name: "index_provider_source_documents_on_provider_source_id"
  end


  create_table "provider_source_licensures", force: :cascade do |t|
    t.bigint "provider_source_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_source_id"], name: "index_provider_source_licensures_on_provider_source_id"
  end

  create_table "provider_source_specialities", force: :cascade do |t|
    t.bigint "provider_source_id", null: false
    t.string "speciality"
    t.boolean "board_certified"
    t.string "certifying_board"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "city"
    t.string "state"
    t.string "zipcode"
    t.string "board_certificate_number"
    t.string "telephone"
    t.string "ext"
    t.string "fax_number"
    t.date "initial_certification_date"
    t.date "expiration_certification_date"
    t.date "recertification_date"
    t.boolean "eligible_certified"
    t.date "admissibility_expiration_date"
    t.boolean "board_exam_results_pending"
    t.string "pending_certifying_board"
    t.string "pending_address_line_1"
    t.string "pending_address_line_2"
    t.string "pending_city"
    t.string "pending_state"
    t.string "pending_zipcode"
    t.string "pending_telephone"
    t.string "pending_ext"
    t.string "pending_fax_number"
    t.date "pending_board_exam_date"
    t.date "board_exam_date"
    t.boolean "applied_for_certification_exam"
    t.boolean "intend_applied_for_certification_exam"
    t.date "intend_date_apply"
    t.text "specialties_no_board_exam_reason"
    t.boolean "accepted_for_certification_exam"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "temp_key"
    t.string "speciality_ranking"
    t.index ["provider_source_id", "temp_key"], name: "idx_pss_on_psid_and_idx", unique: true
    t.index ["provider_source_id"], name: "index_provider_source_specialities_on_provider_source_id"
  end

  create_table "provider_source_undergrad_schools", force: :cascade do |t|
    t.bigint "provider_source_id", null: false
    t.string "school_location"
    t.string "undergraduate_school_name"
    t.string "address_line1"
    t.string "address_line2"
    t.string "city"
    t.string "zipcode"
    t.string "telephone_number"
    t.string "ext"
    t.string "fax_number"
    t.string "email"
    t.string "degree_awarded"
    t.date "date_start"
    t.date "date_graduation"
    t.boolean "incomplete"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "temp_key"
    t.index ["provider_source_id", "temp_key"], name: "idx_psus_on_psid_and_idx", unique: true
    t.index ["provider_source_id"], name: "index_provider_source_undergrad_schools_on_provider_source_id"
  end

  create_table "provider_sources", force: :cascade do |t|
    t.string "status", default: "draft"
    t.boolean "current_provider_source", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "invitation_count", default: 0
    t.datetime "invitation_sent_at"
    t.integer "practice_location_id"
    t.integer "group_engage_provider_id"
    t.integer "created_by_user"
    t.bigint "provider_personal_information_id"
    t.boolean "roster"
    t.index ["provider_personal_information_id"], name: "index_provider_sources_on_provider_personal_information_id"
  end

  create_table "provider_sources_cds", force: :cascade do |t|
    t.bigint "provider_source_id"
    t.string "registration_number"
    t.string "state"
    t.datetime "issue_date"
    t.datetime "expiration_date"
    t.string "practicing_in_state"
    t.string "full_schedule"
    t.text "no_cds_explanation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "schedule_limit_explanation"
    t.index ["provider_source_id"], name: "index_provider_sources_cds_on_provider_source_id"
  end

  create_table "provider_sources_deas", force: :cascade do |t|
    t.bigint "provider_source_id"
    t.string "registration_number"
    t.string "state"
    t.date "issue_date"
    t.date "expiration_date"
    t.string "full_schedule"
    t.string "does_not_expire"
    t.text "schedule_limit_explanation"
    t.string "schedule_helds"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_source_id"], name: "index_provider_sources_deas_on_provider_source_id"
  end


  create_table "provider_sources_licensure", force: :cascade do |t|
    t.bigint "provider_source_id"
    t.string "licensure_state"
    t.string "license_type"
    t.string "license_number"
    t.string "license_status"
    t.date "licensure_issue_date"
    t.date "licensure_expiration_date"
    t.boolean "licensure_not_expire", default: false
    t.boolean "licensure_practice_state"
    t.boolean "licensure_primary_license"
    t.boolean "licensure_require_supervision"
    t.string "licensure_sponsor_fname"
    t.string "licensure_sponsor_mname"
    t.string "licensure_sponsor_lname"
    t.string "licensure_sponsor_suffix"
    t.string "licensure_sponsor_degree"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_source_id"], name: "index_provider_sources_licensure_on_provider_source_id"
  end

  create_table "provider_sources_registrations", force: :cascade do |t|
    t.bigint "provider_source_id"
    t.string "registration_number"
    t.string "specialty"
    t.string "issue_state"
    t.string "issuing_board"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "city"
    t.string "registration_state"
    t.string "zip_code"
    t.string "telephone_number"
    t.string "ext"
    t.string "fax_number"
    t.datetime "issue_date"
    t.datetime "expiration_date"
    t.string "does_not_expire"
    t.string "practicing_under_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_source_id"], name: "index_provider_sources_registrations_on_provider_source_id"
  end


  create_table "provider_specialties", force: :cascade do |t|
    t.integer "caqh_provider_specialty_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.string "board_certified_flag"
    t.datetime "certification_date"
    t.datetime "recertification_date"
    t.datetime "expiration_date"
    t.datetime "future_board_exam_date"
    t.boolean "hmo_flag"
    t.boolean "ppo_flag"
    t.boolean "pos_flag"
    t.boolean "board_certification_expires_flag"
    t.boolean "recertified_flag"
    t.datetime "status_expiration_date"
    t.boolean "results_pending_flag"
    t.boolean "list_in_directory_flag"
    t.string "specialty_board_name"
    t.boolean "failed_board_exam_flag"
    t.string "failed_board_exam_board_name"
    t.datetime "failed_board_exam_date"
    t.boolean "apply_certification_flag"
    t.boolean "intend_apply_certification_flag"
    t.datetime "intend_apply_certification_date"
    t.boolean "exam_accepted_flag"
    t.text "no_certification_explanation"
    t.datetime "admissibility_expiration_date"
    t.boolean "partial_exam_flag"
    t.string "exam_name"
    t.boolean "intending_board_flag"
    t.boolean "not_intending_board_flag"
    t.datetime "exam_taken_date"
    t.boolean "current_certification_flag"
    t.datetime "initial_certification_date"
    t.text "failed_board_exam_explanation"
    t.datetime "future_board_exam_date_oral"
    t.datetime "future_board_exam_date_written"
    t.string "certification_number"
    t.string "specialty_percent"
    t.datetime "status_date"
    t.boolean "abms_flag"
    t.string "results_pending_specialty_board_name"
    t.string "failed_board_exam_attempts"
    t.boolean "not_eligible_board_flag"
    t.datetime "apply_certification_date"
    t.string "specialty_board_address"
    t.string "specialty_board_address2"
    t.string "specialty_board_city"
    t.string "specialty_board_state"
    t.string "specialty_board_postal_code"
    t.text "non_certified_status_non_certified_status_description"
    t.text "specialty_classification_specialty_classification_description"
    t.text "specialty_status_specialty_status_description"
    t.string "sub_specialty_specialty_name"
    t.string "specialty_specialty_name"
    t.text "specialty_type_specialty_type_description"
    t.string "special_experience_skillsand_training_section"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "applied_board_certificate"
    t.string "certification_name"
    t.date "date_applied"
    t.string "tickler"
    t.text "comments"
    t.boolean "planning_to_take_board_exam_flag"
    t.string "board_exam_explanation"
    t.string "audit_status"
    t.boolean "board_certified"
    t.index ["provider_attest_id"], name: "index_provider_specialties_on_provider_attest_id"
  end

  create_table "provider_substance_abuses", force: :cascade do |t|
    t.integer "caqh_provider_substance_abuse_id"
    t.bigint "provider_attest_id"
    t.integer "caqh_provider_attest_id"
    t.text "substance_description"
    t.string "current_ability"
    t.string "monitor_entity_name"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "current_status"
    t.datetime "abstinent_date"
    t.string "provider_name"
    t.string "provider_address"
    t.string "provider_city"
    t.string "provider_telephone"
    t.string "provider_state"
    t.string "monitor_type"
    t.text "disclosure_question_disclosure_summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_attest_id"], name: "index_provider_substance_abuses_on_provider_attest_id"
  end

  create_table "provider_supervisings", force: :cascade do |t|
    t.string "name_of_supervising"
    t.integer "license_state"
    t.string "license_type"
    t.string "license_number"
    t.string "facility"
    t.string "address"
    t.string "mail_stop"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "zipcode"
    t.string "phone_number"
    t.string "fax_number"
    t.string "email_address"
    t.bigint "provider_licensure_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_licensure_id"], name: "index_provider_supervisings_on_provider_licensure_id"
  end

  create_table "provider_taxonomies", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.string "taxonomy_code"
    t.string "specialty"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_taxonomies_on_provider_id"
  end

  create_table "provider_types", force: :cascade do |t|
    t.string "fch"
    t.string "bcbs"
    t.string "perform_rx"
    t.string "dwihn"
    t.string "met_life"
    t.string "pharmpix"
    t.string "broward_health"
    t.string "ochn"
    t.string "primary_partner_care"
    t.string "sdsu_student_health_services"
    t.string "ucamc"
    t.string "macomb_country"
    t.string "nkcph"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "provider_wi_medicaids", force: :cascade do |t|
    t.bigint "provider_id"
    t.string "wi_medicaid"
    t.string "wi_medicaid_username"
    t.string "password"
    t.string "password_digest"
    t.string "question"
    t.string "answer"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_wi_medicaids_on_provider_id"
  end

  create_table "providers", force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "suffix"
    t.string "gender"
    t.date "birth_date"
    t.string "practitioner_type"
    t.string "ssn"
    t.string "npi"
    t.string "caqhid"
    t.date "caqh_attestation_date"
    t.string "caqh_pdf"
    t.date "caqh_pdf_date_received"
    t.string "nccpa_number"
    t.string "dea_number"
    t.date "dea_license_effective_date"
    t.date "dea_license_expiration_date"
    t.string "dco"
    t.string "dco_file"
    t.date "pa_license_effective_date"
    t.date "pa_license_expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "city"
    t.integer "state_id"
    t.string "telephone_number"
    t.string "ext"
    t.string "email_address"
    t.date "provider_hire_date_seeing_patient"
    t.date "effective_date_seeing_patient"
    t.string "medicare_provider_number"
    t.string "medicaid_provider_number"
    t.string "tricare_provider_number"
    t.string "admitting_privileges"
    t.string "revalidation"
    t.string "employed_by_other"
    t.string "supervised_by_psychologist"
    t.string "medical_school_name"
    t.string "medical_school_address"
    t.date "graduation_date"
    t.string "school_certificate"
    t.string "caqh_username"
    t.string "caqh_password"
    t.string "caqh_state"
    t.string "caqh_app"
    t.string "caqh_payor"
    t.string "telehealth_license_number"
    t.string "board_certification_number"
    t.string "dea_registration_state"
    t.string "name_admitting_physician"
    t.string "encoded_by"
    t.string "updated_by"
    t.string "facility_location"
    t.string "facility_name"
    t.string "admitting_facility_address_line1"
    t.string "admitting_facility_address_line2"
    t.string "admitting_facility_city"
    t.string "admitting_facility_zip_code"
    t.string "admitting_facility_arrangments"
    t.integer "enrollment_group_id"
    t.string "api_token"
    t.string "roster_result"
    t.string "terminated"
    t.string "dco_name"
    t.string "taxonomy"
    t.string "specialty"
    t.string "caqh_id"
    t.string "license_number"
    t.string "license_effective_date"
    t.string "license_expiration_date"
    t.string "np_license_number"
    t.string "np_license_effective_date"
    t.string "np_license_expiration_date"
    t.string "rn_license_number"
    t.string "rn_license_effective_date"
    t.string "rn_license_expiration_date"
    t.string "dea_effective_date"
    t.string "dea_expiration_date"
    t.string "liability_issue_date"
    t.string "liability_expiration_date"
    t.string "policy_number"
    t.string "oig"
    t.string "sam"
    t.string "medicare"
    t.string "medicare_revalidation_date"
    t.string "medicaid"
    t.string "medicaid_revalidation_date"
    t.string "molina"
    t.string "mclaren"
    t.string "meridian"
    t.string "aetna"
    t.string "priority_health"
    t.string "amerihealth"
    t.string "telehealth_providers"
    t.string "admitting_facility_state"
    t.string "state_license_copy_file"
    t.string "dea_copy_file"
    t.string "w9_form_file"
    t.string "certificate_insurance_file"
    t.string "drivers_license_file"
    t.string "board_certification_file"
    t.string "caqh_app_copy_file"
    t.string "cv_file"
    t.string "telehealth_license_copy_file"
    t.integer "zip_code"
    t.string "birth_city"
    t.string "birth_state"
    t.string "practice_location_name"
    t.date "provider_effective_date"
    t.string "caqh_login"
    t.date "reattestation_date"
    t.string "security_question_answer"
    t.boolean "board_certified"
    t.string "birth_city_state"
    t.string "medical_school"
    t.string "medical_license"
    t.string "state_license"
    t.date "state_license_effective_date"
    t.date "state_license_expiration_date"
    t.string "pa_license_number"
    t.date "nccpa_expiration_date"
    t.string "ins_policy"
    t.date "ins_policy_effective_date"
    t.date "ins_policy_expiration_date"
    t.date "state_license_effectice_date"
    t.string "status"
    t.datetime "caqh_current_reattestation_date"
    t.string "caqh_reattest_completed_by"
    t.string "caqh_question"
    t.string "caqh_answer"
    t.string "caqh_notes"
    t.integer "licensed_registered_state_id"
    t.string "payer_login", default: "no"
    t.string "license_state_number"
    t.string "license_state_effective_date"
    t.string "license_state_id"
    t.string "license_state_expiration_date"
    t.string "end_date"
    t.string "board_name"
    t.string "board_certificate_number"
    t.date "board_effective_date"
    t.date "board_recertification_date"
    t.date "board_expiration_date"
    t.string "prof_medical_school_name"
    t.string "prof_medical_school_address"
    t.string "prof_medical_school_city"
    t.integer "prof_medical_school_state_id"
    t.string "prof_medical_school_country"
    t.string "prof_medical_school_zipcode"
    t.date "prof_medical_start_date"
    t.string "prof_medical_school_degree_awarded"
    t.string "prof_liability_carrier_name"
    t.string "prof_liability_self_insured"
    t.string "prof_liability_address"
    t.string "prof_liability_city"
    t.integer "prof_liability_state_id"
    t.string "prof_liability_zipcode"
    t.date "prof_liability_orig_effective_date"
    t.date "prof_liability_effective_date"
    t.date "prof_liability_expiration_date"
    t.string "prof_liability_coverage_type"
    t.string "prof_liability_unlimited_coverage"
    t.string "prof_liability_tail_coverage"
    t.string "prof_liability_coverage_amount"
    t.string "prof_liability_coverage_amount_aggregate"
    t.string "prof_liability_policy_number"
    t.string "dcos", default: "f"
    t.date "new_provider_notification"
    t.date "notification_start_date"
    t.date "welcome_letter_sent"
    t.date "notification_enrollment_submit"
    t.string "notification_services"
    t.date "send_welcome_letter"
    t.boolean "welcome_letter_status", default: false
    t.string "welcome_letter_subject"
    t.text "welcome_letter_message"
    t.json "welcome_letter_attachments"
    t.string "dea_not_applicable"
    t.string "cds_not_applicable"
    t.string "rn_not_applicable"
    t.string "aprn_not_applicable"
    t.string "state_not_applicable"
    t.string "dea_explain"
    t.string "cds_explain"
    t.string "rn_explain"
    t.string "cnp_explain"
    t.string "license_explain"
    t.boolean "check_welcome_letter", default: false
    t.boolean "check_co_caqh", default: false
    t.boolean "check_mn_caqh_state_release_form", default: false
    t.boolean "check_mn_caqh_authorization_form", default: false
    t.boolean "check_caqh_standard_authorization", default: false
    t.json "state_license_copies"
    t.json "dea_copies"
    t.json "w9_form_copies"
    t.json "certificate_insurance_copies"
    t.json "driver_license_copies"
    t.json "board_certification_copies"
    t.json "caqh_app_copies"
    t.json "cv_copies"
    t.json "telehealth_license_copies"
    t.string "board_certificate_not_applicable"
    t.string "board_cert_explain"
    t.string "board_specialty_type"
    t.string "supervising_name_npi"
    t.string "supervising_name"
    t.string "supervising_npi"
    t.string "primary_location"

    t.string "payer_login", default: "no"
  end

  create_table "providers_missing_field_submissions", force: :cascade do |t|
    t.bigint "provider_id"
    t.integer "completed_by"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_providers_missing_field_submissions_on_provider_id"
  end

  create_table "providers_missing_field_submissions_data", force: :cascade do |t|
    t.integer "providers_missing_field_submission_id"
    t.string "data_attribute"
    t.string "data_key"
    t.string "data_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "providers_payer_logins", force: :cascade do |t|
    t.bigint "provider_id"
    t.string "enrollment_payer"
    t.integer "state_id"
    t.string "username"
    t.string "password"
    t.string "password_digest"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "cred_current_reattest_date"
    t.date "cred_reattest_date"
    t.index ["provider_id"], name: "index_providers_payer_logins_on_provider_id"
  end

  create_table "providers_payer_logins_questions", force: :cascade do |t|
    t.integer "providers_payer_login_id"
    t.string "question"
    t.string "answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "providers_service_locations", force: :cascade do |t|
    t.bigint "provider_id"
    t.string "primary_service_non_office_area"
    t.string "primary_service_location_apps"
    t.string "primary_service_zip_code"
    t.string "primary_service_office_email"
    t.string "primary_service_fax"
    t.string "primary_service_office_website"
    t.string "primary_service_crisis_phone"
    t.string "primary_service_location_other_phone"
    t.string "primary_service_appt_scheduling"
    t.string "primary_service_interpreter_language"
    t.string "primary_service_telehealth_only_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_providers_service_locations_on_provider_id"
  end

  create_table "providers_time_lines", force: :cascade do |t|
    t.bigint "provider_id"
    t.string "title"
    t.datetime "due_date"
    t.string "notes"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_providers_time_lines_on_provider_id"
  end

  create_table "references", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "middle_name"
    t.string "last_name", null: false
    t.string "suffix"
    t.string "degree", null: false
    t.string "specialty"
    t.string "contact_method", null: false
    t.string "address_line1", null: false
    t.string "address_line2"
    t.string "city", null: false
    t.string "state", null: false
    t.string "zipcode", null: false
    t.string "telephone_number", null: false
    t.string "ext"
    t.string "fax", null: false
    t.boolean "does_not_have_fax", default: false
    t.string "mobile_number"
    t.string "email_address", null: false
    t.date "association_start_date", null: false
    t.date "association_end_date"
    t.boolean "association_until_present", default: false
    t.string "relationship"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "review_level_changes", force: :cascade do |t|
    t.bigint "provider_personal_information_id", null: false
    t.string "changed_by"
    t.string "from_level"
    t.string "to_level"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_personal_information_id"], name: "index_review_level_changes_on_provider_personal_information_id"
  end

  create_table "role_based_accesses", force: :cascade do |t|
    t.string "role"
    t.string "page"
    t.boolean "can_create"
    t.boolean "can_read"
    t.boolean "can_update"
    t.boolean "can_delete"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end


  create_table "rva_informations", force: :cascade do |t|
    t.string "tab"
    t.string "send_request"
    t.string "requested_by"
    t.date "requested_date"
    t.string "requested_method"
    t.decimal "required_fee_amount", precision: 10, scale: 2
    t.string "check_payable_to"
    t.boolean "include_delineation", default: false
    t.boolean "check_generated"
    t.boolean "received_status"
    t.string "received_by"
    t.date "received_date"
    t.text "comments"
    t.string "source_name"
    t.date "source_date"
    t.string "status"
    t.boolean "adverse_action"
    t.text "other_details"
    t.text "adverse_action_comments"
    t.text "adverse_action_status"
    t.string "verification_status"
    t.boolean "in_good_standing", default: false
    t.string "error_type"
    t.text "error_comments"
    t.string "correct_info_selected"
    t.string "correct_info_text"
    t.string "notification_status"
    t.date "verification_date"
    t.string "verifier"
    t.text "verification_comments"
    t.string "audit_reason"
    t.text "audit_reason_comments"
    t.boolean "audit_status"
    t.date "audit_date"
    t.string "auditor"
    t.text "audit_comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "provider_personal_information_id"
    t.bigint "provider_dea_id"
    t.bigint "practice_information_education_id"
    t.bigint "provider_education_id"
    t.bigint "provider_specialty_id"
    t.bigint "provider_licensure_id"
    t.bigint "provider_insurance_coverage_id"
    t.bigint "provider_employment_id"
    t.bigint "certification_id"
    t.index ["certification_id"], name: "index_rva_informations_on_certification_id"
    t.index ["practice_information_education_id"], name: "index_rva_informations_on_practice_information_education_id"
    t.index ["provider_dea_id"], name: "index_rva_informations_on_provider_dea_id"
    t.index ["provider_education_id"], name: "index_rva_informations_on_provider_education_id"
    t.index ["provider_employment_id"], name: "index_rva_informations_on_provider_employment_id"
    t.index ["provider_insurance_coverage_id"], name: "index_rva_informations_on_provider_insurance_coverage_id"
    t.index ["provider_licensure_id"], name: "index_rva_informations_on_provider_licensure_id"
    t.index ["provider_personal_information_id"], name: "index_rva_informations_on_provider_personal_information_id"
    t.index ["provider_specialty_id"], name: "index_rva_informations_on_provider_specialty_id"
  end

  create_table "saved_profiles", force: :cascade do |t|
    t.string "file_path"
    t.string "file_type"
    t.bigint "pdf_generation_queue_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pdf_generation_queue_id"], name: "index_saved_profiles_on_pdf_generation_queue_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "suite"
    t.string "address2"
    t.string "city"
    t.string "county"
    t.string "state"
    t.string "postal_code"
    t.string "country"
    t.string "contact_method"
    t.string "phone"
    t.string "fax"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "serviced_populations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "services", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string "theme_color"
    t.string "font_style"
    t.string "logo_file"
    t.string "dark_mode", default: "NO"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "client_name"
    t.boolean "enable_otp", default: true
  end

  create_table "specialties", force: :cascade do |t|
    t.string "fch"
    t.string "bcbs"
    t.string "perform_rx"
    t.string "dwihn"
    t.string "met_life"
    t.string "pharmpix"
    t.string "broward_health"
    t.string "ochn"
    t.string "primary_partner_care"
    t.string "sdsu_student_health_services"
    t.string "ucamc"
    t.string "macomb_country"
    t.string "nkcph"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "specialty_details", force: :cascade do |t|
    t.string "ranking"
    t.string "specialty"
    t.boolean "certified"
    t.string "certifying_board"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "board_certificate"
    t.string "telephone"
    t.date "initial_date"
    t.date "expiration_date"
    t.boolean "ppo_directory"
    t.boolean "pos_directory"
    t.boolean "provider_directory"
    t.boolean "hmo_directory"
    t.boolean "board_certified"
    t.boolean "certified_eligible"
    t.boolean "failed_exam"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "target_population_privileges"
    t.string "populations_employment_type"
    t.string "populations_served"
    t.boolean "specialty_student_intern"
    t.text "populations_infos"
    t.text "populations_served_text"
    t.date "failed_exam_date"
    t.string "failed_exam_certifying_board"
    t.text "failed_exam_reason"
    t.date "certification_expiry"
  end

  create_table "staff_spoken_foreign_languages", force: :cascade do |t|
    t.string "language"
    t.boolean "is_spoken", default: false
    t.boolean "is_read", default: false
    t.boolean "is_write", default: false
    t.boolean "is_interpreter_available", default: false
    t.string "specific_language"
    t.bigint "practice_information_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["practice_information_id"], name: "index_staff_spoken_foreign_languages_on_practice_information_id"
  end

  create_table "states", force: :cascade do |t|
    t.string "name"
    t.string "alpha_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "color"
  end

  create_table "tbl_ii", id: false, force: :cascade do |t|
    t.integer "id"
    t.string "tbl_II_ID", limit: 50
    t.string "PractitionerGUID", limit: 50
    t.string "FirstName", limit: 50
    t.string "MiddleName", limit: 50
    t.string "LastName", limit: 50
    t.string "Suffix", limit: 50
    t.integer "HavingOtherNameOrNot"
    t.string "tbl_InsTable_OtherName_ID", limit: 50
    t.string "tbl_InsTable_HomeAddress_ID", limit: 50
    t.string "ContactMethod", limit: 50
    t.string "HomePhone", limit: 50
    t.string "HomeFax", limit: 50
    t.string "PersonalEmail", limit: 50
    t.string "Phone", limit: 50
    t.string "Fax", limit: 50
    t.string "Email", limit: 50
    t.string "BirthDate", limit: 50
    t.string "BirthCity", limit: 50
    t.string "BirthState", limit: 50
    t.string "BirthCountry", limit: 50
    t.integer "USCitizenOrNot"
    t.string "CountryOfCitizenship", limit: 50
    t.integer "Eligible"
    t.string "AlienRegisNum", limit: 50
    t.string "VisaStatus", limit: 50
    t.string "VisaNumber", limit: 50
    t.integer "Gender"
    t.string "Ethnicity", limit: 50
    t.string "FedEmployeeID", limit: 50
    t.string "SSN", limit: 50
    t.string "PractitionerType", limit: 50
    t.string "PractitionerTypeOther", limit: 50
    t.integer "PriCarePractitioner"
    t.integer "SpeciaList"
    t.integer "AlliedProfessional"
    t.string "PriSpecialty", limit: 50
    t.string "SecSpecialty", limit: 50
    t.string "TerSpecialty", limit: 50
    t.string "OtherAreas", limit: 50
    t.integer "MakeHouseCallsOrNot"
    t.string "OcularPharAgent", limit: 50
    t.string "TherapeuticPharAgent", limit: 50
    t.string "DiagnosticPharAgent", limit: 50
    t.string "Comments", limit: 128
    t.string "VerificationCompleteDate", limit: 50
    t.integer "QualityAuditComplete"
    t.string "DateCreated", limit: 50
    t.string "WebPages", limit: 50
    t.string "MaritalStatus", limit: 50
    t.string "SpouseFirstName", limit: 50
    t.string "SpouseMiddleName", limit: 50
    t.string "SpouseLastName", limit: 50
    t.string "CredentialContactFirstName", limit: 50
    t.string "CredentialContactTitle", limit: 50
    t.string "CredentialContactLastName", limit: 50
    t.string "CredentialContactSuffix", limit: 50
    t.string "CredentialContactMethod", limit: 50
    t.string "CredentialPhone", limit: 50
    t.string "CredentialFax", limit: 50
    t.string "CredentialEmail", limit: 50
    t.string "CredentialAddress", limit: 50
    t.string "CredentialAdditionalAddress", limit: 64
    t.string "CredentialSuite", limit: 50
    t.string "CredentialCity", limit: 50
    t.string "CredentialState", limit: 50
    t.string "CredentialZip", limit: 50
    t.string "CredentialCountry", limit: 50
    t.string "CredentialCounty", limit: 50
    t.string "ConfContactMethod", limit: 50
    t.string "ConfPhone", limit: 50
    t.string "ConfFax", limit: 50
    t.string "ConfEmail", limit: 50
    t.string "ConfAddress", limit: 50
    t.string "ConfAdditionalAddress", limit: 50
    t.string "ConfSuite", limit: 50
    t.string "ConfCity", limit: 50
    t.string "ConfState", limit: 50
    t.string "ConfZip", limit: 50
    t.string "ConfCountry", limit: 50
    t.string "ConfCounty", limit: 50
    t.string "ConfContactTitle", limit: 50
    t.string "ConfContactFirstName", limit: 50
    t.string "ConfContactLastName", limit: 50
    t.string "ConfContactSuffix", limit: 50
    t.string "CredentialMobilePhone", limit: 50
    t.string "Title", limit: 50
    t.string "ConfMobilePhone", limit: 50
    t.string "AdditionalPractitionerType", limit: 50
    t.integer "AvailabilityForCall"
    t.string "PracID", limit: 50
    t.string "Religion", limit: 50
    t.integer "RelocateOrNot"
    t.string "RelocationDate", limit: 50
    t.string "PractitionerSignatory", limit: 50
    t.string "PracticingSpecialty", limit: 50
    t.string "Specialty1", limit: 50
    t.string "Specialty2", limit: 50
    t.string "Specialty3", limit: 50
    t.string "Specialty4", limit: 50
    t.string "Specialty5", limit: 50
    t.string "Mkt", limit: 50
    t.string "FloridaID", limit: 50
    t.string "CustomID1", limit: 50
    t.string "CustomID2", limit: 50
    t.string "CustomID3", limit: 50
  end

  create_table "training_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transaction_logs", force: :cascade do |t|
    t.bigint "client_organization_id", null: false
    t.string "solana_tx"
    t.string "status"
    t.string "memo"
    t.bigint "order_id"
    t.decimal "amount"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_sidebar_preferences", force: :cascade do |t|
    t.bigint "user_id"
    t.string "collapse_name"
    t.boolean "is_open", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_sidebar_preferences_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "user_type"
    t.string "following_request"
    t.string "middle_name"
    t.string "suffix"
    t.string "status"
    t.string "from_source"
    t.string "user_role"
    t.string "temporary_password"
    t.string "temporary_password_confirmation"
    t.string "title"
    t.string "api_token"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "otp_token"
    t.string "otp_code"
    t.datetime "otp_code_expires_at"
    t.boolean "logout_on_close", default: false
    t.datetime "last_logout_on_close"
    t.boolean "can_access_all_groups"
    t.boolean "is_provider_account"
    t.string "accessible_provider"
    t.string "password_change_status_via_invite"

    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.string "security_question"
    t.string "security_answer"
    t.string "provider"
    t.string "uid"
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_enrollment_groups", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "enrollment_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_group_id"], name: "index_users_enrollment_groups_on_enrollment_group_id"
    t.index ["user_id"], name: "index_users_enrollment_groups_on_user_id"
  end

  create_table "verification_products", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.decimal "price", precision: 12, scale: 6, default: "0.0"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "verification_tasks", force: :cascade do |t|
    t.bigint "provider_profile_id", null: false
    t.bigint "verification_product_id", null: false
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_profile_id"], name: "index_verification_tasks_on_provider_profile_id"
    t.index ["verification_product_id"], name: "index_verification_tasks_on_verification_product_id"
  end

  create_table "virtual_review_committees", force: :cascade do |t|
    t.string "provider_name"
    t.string "provider_type"
    t.string "state"
    t.string "cred_cycle"
    t.datetime "psv_completed_date"
    t.string "review_level"
    t.datetime "recred_due_date"
    t.datetime "review_date"
    t.datetime "committee_date"
    t.datetime "vote_date"
    t.string "status"
    t.string "progress_status", default: "completed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "client_id"
    t.integer "provider_id"
    t.string "provider_cycle_id"
    t.integer "medv_id"
    t.string "first_name"
    t.string "last_name"
    t.string "cred_or_recred"
    t.string "app_complete_data"
    t.string "voted_by"
    t.string "specialty"
    t.string "region"
    t.string "committee_approval_date"
    t.string "assignment_indicator"
    t.string "orig_synch_date"
    t.string "review_details"
  end

  create_table "visa_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vrc_documents", force: :cascade do |t|
    t.string "name"
    t.date "committee_date"
    t.string "file_upload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "webcrawler_logs", force: :cascade do |t|
    t.string "crawler_type"
    t.string "filepath"
    t.string "filetype"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "webscraper_alaska_states", force: :cascade do |t|
    t.string "program"
    t.string "license_number"
    t.string "dba"
    t.string "owners"
    t.string "status"
    t.string "license_expiration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "webscraper_california_states", force: :cascade do |t|
    t.string "name"
    t.string "license_number"
    t.string "license_type"
    t.string "license_status"
    t.string "license_expiration"
    t.string "secondary_status"
    t.string "city"
    t.string "state"
    t.string "county"
    t.string "zip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "admitting_arrangements", "provider_sources"
  add_foreign_key "certifications", "provider_attests"
  add_foreign_key "dea_webcrawler_logs", "rva_informations"
  add_foreign_key "director_providers", "provider_personal_informations"
  add_foreign_key "director_providers", "users"
  add_foreign_key "director_providers", "virtual_review_committees"
  add_foreign_key "egd_logs", "enroll_groups_details"
  add_foreign_key "enrollment_group_deleted_doc_logs", "enrollment_groups"
  add_foreign_key "epd_logs", "enrollment_providers_details"
  add_foreign_key "epd_questions", "enrollment_providers_details"
  add_foreign_key "graduate_details", "provider_sources"
  add_foreign_key "group_contacts", "enrollment_groups"
  add_foreign_key "group_dco_old_location_addresses", "group_dcos"
  add_foreign_key "group_dcos", "enrollment_groups"
  add_foreign_key "hospital_privileges", "provider_sources"
  add_foreign_key "licensure_webcrawler_logs", "rva_informations"
  add_foreign_key "oig_webcrawler_logs", "rva_informations"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "verification_products"
  add_foreign_key "orders", "client_organizations"
  add_foreign_key "other_names", "provider_sources"
  add_foreign_key "payments", "orders"
  add_foreign_key "pdf_generation_queues", "provider_personal_informations"
  add_foreign_key "pdf_queue_items", "pdf_generation_queues"
  add_foreign_key "practice_locations", "practice_informations"
  add_foreign_key "professional_organizations", "provider_attests"
  add_foreign_key "provider_deleted_document_logs", "providers"
  add_foreign_key "provider_employments", "provider_attests"
  add_foreign_key "provider_licenses", "providers"
  add_foreign_key "provider_licensures", "provider_attests"
  add_foreign_key "provider_np_licenses", "providers"

  add_foreign_key "provider_npdb_comments", "provider_npdbs"
  add_foreign_key "provider_npdb_comments", "users"
  add_foreign_key "provider_npdbs", "provider_attests"
  add_foreign_key "provider_personal_information_app_trackings", "provider_personal_informations"
  add_foreign_key "provider_personal_information_comments", "provider_personal_informations"
  add_foreign_key "provider_personal_information_comments", "users"
  add_foreign_key "provider_profiles", "orders"
  add_foreign_key "provider_profiles", "providers"
  add_foreign_key "provider_rn_licenses", "providers"
  add_foreign_key "provider_source_data", "provider_sources"
  add_foreign_key "provider_source_documents", "provider_sources"
  add_foreign_key "provider_source_licensures", "provider_sources"
  add_foreign_key "provider_source_specialities", "provider_sources"
  add_foreign_key "provider_source_undergrad_schools", "provider_sources"
  add_foreign_key "provider_sources", "provider_personal_informations"
  add_foreign_key "provider_taxonomies", "providers"
  add_foreign_key "review_level_changes", "provider_personal_informations"
  add_foreign_key "rva_informations", "certifications"
  add_foreign_key "rva_informations", "practice_information_educations"
  add_foreign_key "rva_informations", "provider_deas"
  add_foreign_key "rva_informations", "provider_educations"
  add_foreign_key "rva_informations", "provider_employments"
  add_foreign_key "rva_informations", "provider_insurance_coverages"
  add_foreign_key "rva_informations", "provider_licensures"
  add_foreign_key "rva_informations", "provider_personal_informations"
  add_foreign_key "rva_informations", "provider_specialties"
  add_foreign_key "saved_profiles", "pdf_generation_queues"
  add_foreign_key "verification_tasks", "provider_profiles"
  add_foreign_key "verification_tasks", "verification_products"
end
