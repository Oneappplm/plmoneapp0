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

ActiveRecord::Schema[7.0].define(version: 2023_07_25_025450) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

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
    t.index ["enrollment_provider_id"], name: "index_enrollment_providers_details_on_enrollment_provider_id"
  end

  create_table "epd_logs", force: :cascade do |t|
    t.bigint "enrollment_providers_detail_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_providers_detail_id"], name: "index_epd_logs_on_enrollment_providers_detail_id"
  end

  create_table "group_dco_contacts", force: :cascade do |t|
    t.bigint "group_dco_id"
    t.string "department"
    t.string "name"
    t.string "role"
    t.string "phone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_dco_id"], name: "index_group_dco_contacts_on_group_dco_id"
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
    t.index ["enrollment_group_id"], name: "index_group_dcos_on_enrollment_group_id"
  end

  create_table "health_plans", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "privilege_statuses", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "provider_cnp_licenses", force: :cascade do |t|
    t.bigint "provider_id"
    t.string "cnp_license_number"
    t.datetime "effective_date"
    t.datetime "expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["provider_id"], name: "index_provider_dea_licenses_on_provider_id"
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

  create_table "provider_ins_policies", force: :cascade do |t|
    t.bigint "provider_id"
    t.string "ins_policy_number"
    t.datetime "effective_date"
    t.datetime "expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_ins_policies_on_provider_id"
  end

  create_table "provider_licenses", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.string "license_number"
    t.date "license_effective_date"
    t.date "license_expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "state_id"
    t.index ["provider_id"], name: "index_provider_licenses_on_provider_id"
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

  create_table "provider_np_licenses", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.string "np_license_number"
    t.date "np_license_effective_date"
    t.date "np_license_expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_np_licenses_on_provider_id"
  end

  create_table "provider_pa_licenses", force: :cascade do |t|
    t.bigint "provider_id"
    t.string "pa_license_number"
    t.datetime "pa_license_effective_date"
    t.datetime "pa_license_expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_pa_licenses_on_provider_id"
  end

  create_table "provider_rn_licenses", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.string "rn_license_number"
    t.date "rn_license_effective_date"
    t.date "rn_license_expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_rn_licenses_on_provider_id"
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

  create_table "provider_sources", force: :cascade do |t|
    t.string "status", default: "draft"
    t.boolean "current_provider_source", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "invitation_count", default: 0
    t.datetime "invitation_sent_at"
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

  create_table "states", force: :cascade do |t|
    t.string "name"
    t.string "alpha_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "color"
  end

  create_table "training_types", force: :cascade do |t|
    t.string "name"
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
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
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

  add_foreign_key "epd_logs", "enrollment_providers_details"
  add_foreign_key "group_dco_old_location_addresses", "group_dcos"
  add_foreign_key "group_dcos", "enrollment_groups"
  add_foreign_key "provider_deleted_document_logs", "providers"
  add_foreign_key "provider_licenses", "providers"
  add_foreign_key "provider_np_licenses", "providers"
  add_foreign_key "provider_rn_licenses", "providers"
  add_foreign_key "provider_source_data", "provider_sources"
  add_foreign_key "provider_source_documents", "provider_sources"
  add_foreign_key "provider_taxonomies", "providers"
end
