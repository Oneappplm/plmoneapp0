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

ActiveRecord::Schema[7.0].define(version: 2023_05_09_234655) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "group_id"
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
    t.string "status"
    t.string "application_id"
    t.string "not_submitted_note"
    t.string "not_submitted_note_rejected"
    t.datetime "approved_date"
    t.string "approved_confirmation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "provider_id"
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
    t.string "country"
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

  create_table "provider_licenses", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.string "license_number"
    t.date "license_effective_date"
    t.date "license_expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_licenses_on_provider_id"
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
    t.string "state"
    t.string "telephone_number"
    t.string "ext"
    t.string "email_address"
    t.string "dea_registration_date"
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
    t.index ["email"], name: "index_users_on_email", unique: true
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

  add_foreign_key "group_dcos", "enrollment_groups"
  add_foreign_key "provider_licenses", "providers"
  add_foreign_key "provider_np_licenses", "providers"
  add_foreign_key "provider_rn_licenses", "providers"
  add_foreign_key "provider_source_data", "provider_sources"
  add_foreign_key "provider_source_documents", "provider_sources"
  add_foreign_key "provider_taxonomies", "providers"
end
