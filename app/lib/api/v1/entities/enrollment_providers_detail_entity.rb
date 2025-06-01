module Api
  module V1
    module Entities
      class EnrollmentProvidersDetailEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the detail record.' }
        expose :enrollment_provider_id, documentation: { type: 'Integer', desc: 'ID of the parent EnrollmentProvider.' }
        expose :start_date, documentation: { type: 'Date', desc: 'Start date for this detail.' }
        expose :due_date, documentation: { type: 'Date', desc: 'Due date for this detail.' }
        expose :enrollment_payer, documentation: { type: 'String', desc: 'Enrollment payer for this detail.' }
        expose :enrollment_type, documentation: { type: 'String', desc: 'Enrollment type for this detail.' }
        expose :enrollment_status, documentation: { type: 'String', desc: 'Enrollment status for this detail.' }
        expose :ptan_number, documentation: { type: 'String', desc: 'PTAN number.' }
        expose :approved_date, documentation: { type: 'Date', desc: 'Date approved.' }
        expose :revalidation_date, documentation: { type: 'Date', desc: 'Revalidation date.' }
        expose :revalidation_due_date, documentation: { type: 'Date', desc: 'Revalidation due date.' }
        expose :comment, documentation: { type: 'String', desc: 'Comment associated with this detail.' }
        expose :provider_ptan, documentation: { type: 'String', desc: 'Provider PTAN.' }
        expose :group_ptan, documentation: { type: 'String', desc: 'Group PTAN.' }
        expose :enrollment_tracking_id, documentation: { type: 'Integer', desc: 'Enrollment tracking ID.' }
        expose :enrollment_effective_date, documentation: { type: 'String', desc: 'Enrollment effective date.' }
        expose :association_start_date, documentation: { type: 'String', desc: 'Association start date.' }
        expose :business_end_date, documentation: { type: 'String', desc: 'Business end date.' }
        expose :association_end_date, documentation: { type: 'String', desc: 'Association end date.' }
        expose :line_of_business, documentation: { type: 'String', desc: 'Line of business.' }
        expose :revalidation_status, documentation: { type: 'String', desc: 'Revalidation status.' }
        expose :cpt_code, documentation: { type: 'String', desc: 'CPT code.' }
        expose :descriptor, documentation: { type: 'String', desc: 'Descriptor.' }
        expose :provider_id, documentation: { type: 'String', desc: 'Provider ID (string type in schema).' }
        expose :group_id, documentation: { type: 'String', desc: 'Group ID (string type in schema).' }
        expose :payer_state, documentation: { type: 'String', desc: 'Payer state.' }
        expose :upload_payor_file, documentation: { type: 'JSON', desc: 'Uploaded payor file info.' }
        expose :payor_username, documentation: { type: 'String', desc: 'Payor username.' }
        expose :payor_password, documentation: { type: 'String', desc: 'Payor password (Sensitive).' }
        expose :processing_date, documentation: { type: 'String', desc: 'Processing date.' }
        expose :terminated_date, documentation: { type: 'String', desc: 'Termination date.' }
        expose :denied_date, documentation: { type: 'Date', desc: 'Denied date.' }
        expose :payor_email, documentation: { type: 'String', desc: 'Payor email.' }
        expose :payor_phone, documentation: { type: 'String', desc: 'Payor phone.' }
        expose :tax_id, documentation: { type: 'String', desc: 'Tax ID.' }
        expose :location, documentation: { type: 'String', desc: 'Location.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
