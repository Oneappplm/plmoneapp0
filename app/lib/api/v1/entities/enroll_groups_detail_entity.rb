module Api
  module V1
    module Entities
      class EnrollGroupsDetailEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the detail record.' }
        expose :enroll_group_id, documentation: { type: 'Integer', desc: 'ID of the parent EnrollGroup.' }
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
        expose :state_id, documentation: { type: 'Integer', desc: 'Associated state ID.' }
        expose :group_number, documentation: { type: 'String', desc: 'Group number.' }
        expose :effective_date, documentation: { type: 'DateTime', desc: 'Effective date.' }
        expose :application_status, documentation: { type: 'String', desc: 'Application status.' }
        expose :payor_type, documentation: { type: 'String', desc: 'Payor type.' }
        expose :medicare_tricare, documentation: { type: 'String', desc: 'Medicare/Tricare info.' }
        expose :payor_name, documentation: { type: 'String', desc: 'Payor name.' }
        expose :payor_phone, documentation: { type: 'String', desc: 'Payor phone number.' }
        expose :payor_email, documentation: { type: 'String', desc: 'Payor email address.' }
        expose :enrollment_link, documentation: { type: 'String', desc: 'Enrollment link.' }
        expose :payor_username, documentation: { type: 'String', desc: 'Payor username.' }
        expose :password, documentation: { type: 'String', desc: 'Payor password (Sensitive).' }
        expose :payor_question, documentation: { type: 'String', desc: 'Payor security question.' }
        expose :payor_answer, documentation: { type: 'String', desc: 'Payor security answer.' }
        expose :portal_admin, documentation: { type: 'String', desc: 'Portal admin info.' }
        expose :portal_admin_name, documentation: { type: 'String', desc: 'Portal admin name.' }
        expose :portal_admin_phone, documentation: { type: 'String', desc: 'Portal admin phone.' }
        expose :portal_admin_email, documentation: { type: 'String', desc: 'Portal admin email.' }
        expose :caqh_payer, documentation: { type: 'String', desc: 'CAQH payer info.' }
        expose :eft, documentation: { type: 'String', desc: 'EFT status/info.' }
        expose :era, documentation: { type: 'String', desc: 'ERA status/info.' }
        expose :client_notes, documentation: { type: 'String', desc: 'Client notes.' }
        expose :notes, documentation: { type: 'String', desc: 'General notes.' }
        expose :payer_state, documentation: { type: 'String', desc: 'Payer state.' }
        expose :payor_submission_type, documentation: { type: 'String', desc: 'Payor submission type.' }
        expose :payor_link, documentation: { type: 'String', desc: 'Payor link.' }
        expose :portal_username, documentation: { type: 'String', desc: 'Portal username.' }
        expose :portal_password, documentation: { type: 'String', desc: 'Portal password (Sensitive).' }
        expose :upload_payor_file, documentation: { type: 'JSON', desc: 'Uploaded payor file info.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the detail was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the detail was last updated.' }
      end
    end
  end
end
