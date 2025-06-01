module Api
  module V1
    module Entities
      class EnrollGroupEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the enrollment group.' }
        expose :name, documentation: { type: 'String', desc: 'Name of the enrollment group.' }
        expose :first_name, documentation: { type: 'String', desc: 'Contact person first name.' }
        expose :middle_name, documentation: { type: 'String', desc: 'Contact person middle name.' }
        expose :last_name, documentation: { type: 'String', desc: 'Contact person last name.' }
        expose :suffix, documentation: { type: 'String', desc: 'Contact person suffix.' }
        expose :email, documentation: { type: 'String', desc: 'Contact email for the group.' }
        expose :telephone_number, documentation: { type: 'String', desc: 'Contact telephone number.' }
        expose :medicare_ptan, documentation: { type: 'String', desc: 'Medicare PTAN number.' }
        expose :medicaid_group_number, documentation: { type: 'String', desc: 'Medicaid group number.' }
        expose :bcbs_number, documentation: { type: 'String', desc: 'BCBS number.' }
        expose :tricate_military, documentation: { type: 'String', desc: 'Tricare military info.' }
        expose :commercial_name, documentation: { type: 'String', desc: 'Commercial name.' }
        expose :contracted, documentation: { type: 'String', desc: 'Contracted status.' }
        expose :revalidated, documentation: { type: 'String', desc: 'Revalidated status.' }
        expose :revalidated_payer_name, documentation: { type: 'String', desc: 'Name of revalidating payer.' }
        expose :application_contracts, documentation: { type: 'String', desc: 'Application contracts info.' }
        expose :application_payer_name, documentation: { type: 'String', desc: 'Name of application payer.' }
        expose :with_medicare, documentation: { type: 'String', desc: 'Medicare association status.' }
        expose :with_eft, documentation: { type: 'String', desc: 'EFT status.' }
        expose :with_edi, documentation: { type: 'String', desc: 'EDI status.' }
        expose :start_date, documentation: { type: 'DateTime', desc: 'Enrollment start date.' }
        expose :due_date, documentation: { type: 'DateTime', desc: 'Enrollment due date.' }
        expose :payer, documentation: { type: 'String', desc: 'Associated payer.' }
        expose :revalidation_date, documentation: { type: 'DateTime', desc: 'Revalidation date.' }
        expose :enrollment_type, documentation: { type: 'String', desc: 'Type of enrollment.' }
        expose :status, documentation: { type: 'String', desc: 'Current status of the enrollment group.' }
        expose :group_id, documentation: { type: 'Integer', desc: 'Associated Group ID (if applicable).' }
        expose :user_id, documentation: { type: 'Integer', desc: 'ID of the associated User.' }
        expose :outreach_type, documentation: { type: 'String', desc: 'Type of outreach.' }
        expose :enrollment_payer, documentation: { type: 'String', desc: 'Specific enrollment payer.' }
        expose :voided_bank_letter, documentation: { type: 'String', desc: 'Voided bank letter info/status.' }
        expose :dco, documentation: { type: 'Integer', desc: 'DCO identifier.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the group was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp when the group was last updated.' }
      end
    end
  end
end
