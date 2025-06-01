module Api
  module V1
    module Entities
      class EnrollmentProviderEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the enrollment provider record.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'ID of the associated Provider.' }
        expose :user_id, documentation: { type: 'Integer', desc: 'ID of the associated User.' }
        expose :name, documentation: { type: 'String', desc: 'Name associated with the enrollment.' }
        expose :first_name, documentation: { type: 'String', desc: 'First name.' }
        expose :middle_name, documentation: { type: 'String', desc: 'Middle name.' }
        expose :last_name, documentation: { type: 'String', desc: 'Last name.' }
        expose :suffix, documentation: { type: 'String', desc: 'Suffix.' }
        expose :telephone_number, documentation: { type: 'String', desc: 'Telephone number.' }
        expose :email_address, documentation: { type: 'String', desc: 'Email address.' }
        expose :start_date, documentation: { type: 'DateTime', desc: 'Enrollment start date.' }
        expose :due_date, documentation: { type: 'DateTime', desc: 'Enrollment due date.' }
        expose :enrollment_payer, documentation: { type: 'String', desc: 'Enrollment payer.' }
        expose :revalidation_date, documentation: { type: 'DateTime', desc: 'Revalidation date.' }
        expose :enrollment_type, documentation: { type: 'String', desc: 'Type of enrollment.' }
        expose :status, documentation: { type: 'String', desc: 'Current status.' }
        expose :application_id, documentation: { type: 'String', desc: 'Application ID.' }
        expose :approved_date, documentation: { type: 'DateTime', desc: 'Date approved.' }
        expose :approved_confirmation, documentation: { type: 'String', desc: 'Approval confirmation details.' }
        expose :outreach_type, documentation: { type: 'String', desc: 'Type of outreach.' }
        expose :enrolled_by, documentation: { type: 'String', desc: 'Who performed the enrollment.' }
        expose :updated_by, documentation: { type: 'String', desc: 'Who last updated the record.' }
        expose :state_license_submitted, documentation: { type: 'DateTime', desc: 'Timestamp state license submitted.' }
        expose :dea_submitted, documentation: { type: 'DateTime', desc: 'Timestamp DEA submitted.' }
        expose :irs_letter_submitted, documentation: { type: 'DateTime', desc: 'Timestamp IRS letter submitted.' }
        expose :w9_submitted, documentation: { type: 'DateTime', desc: 'Timestamp W9 submitted.' }
        expose :voided_check_submitted, documentation: { type: 'DateTime', desc: 'Timestamp voided check submitted.' }
        expose :curriculum_vitae_submitted, documentation: { type: 'DateTime', desc: 'Timestamp CV submitted.' }
        expose :cms_460_submitted, documentation: { type: 'DateTime', desc: 'Timestamp CMS 460 submitted.' }
        expose :eft_submitted, documentation: { type: 'DateTime', desc: 'Timestamp EFT submitted.' }
        expose :cert_insurance_submitted, documentation: { type: 'DateTime', desc: 'Timestamp certificate of insurance submitted.' }
        expose :driver_license_submitted, documentation: { type: 'DateTime', desc: 'Timestamp driver license submitted.' }
        expose :board_certification_submitted, documentation: { type: 'DateTime', desc: 'Timestamp board certification submitted.' }
        expose :not_submitted_note, documentation: { type: 'String', desc: 'Note if not submitted.' }
        expose :not_submitted_note_rejected, documentation: { type: 'String', desc: 'Note if rejected.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
