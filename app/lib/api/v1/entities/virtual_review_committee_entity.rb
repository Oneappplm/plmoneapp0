module Api
  module V1
    module Entities
      class VirtualReviewCommitteeEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the committee record.' }
        expose :provider_name, documentation: { type: 'String', desc: 'Provider name associated with the review.' }
        expose :provider_type, documentation: { type: 'String', desc: 'Type of the provider.' }
        expose :state, documentation: { type: 'String', desc: 'State associated with the review.' }
        expose :cred_cycle, documentation: { type: 'String', desc: 'Credentialing cycle.' }
        expose :psv_completed_date, documentation: { type: 'DateTime', desc: 'Date PSV was completed.' }
        expose :review_level, documentation: { type: 'String', desc: 'Level of review.' }
        expose :recred_due_date, documentation: { type: 'DateTime', desc: 'Recredentialing due date.' }
        expose :review_date, documentation: { type: 'DateTime', desc: 'Date of review.' }
        expose :committee_date, documentation: { type: 'DateTime', desc: 'Date committee met.' }
        expose :vote_date, documentation: { type: 'DateTime', desc: 'Date vote occurred.' }
        expose :status, documentation: { type: 'String', desc: 'Current status of the review.' }
        expose :progress_status, documentation: { type: 'String', desc: 'Progress status.' }
        expose :client_id, documentation: { type: 'Integer', desc: 'Associated Client ID.' }
        expose :provider_id, documentation: { type: 'Integer', desc: 'Associated Provider ID.' }
        expose :provider_cycle_id, documentation: { type: 'String', desc: 'Provider cycle ID.' }
        expose :medv_id, documentation: { type: 'Integer', desc: 'Associated MedV ID.' }
        expose :first_name, documentation: { type: 'String', desc: 'First name (duplicate of provider?).' }
        expose :last_name, documentation: { type: 'String', desc: 'Last name (duplicate of provider?).' }
        expose :cred_or_recred, documentation: { type: 'String', desc: 'Credentialing or recredentialing indicator.' }
        expose :app_complete_data, documentation: { type: 'String', desc: 'Application complete data/date.' }
        expose :voted_by, documentation: { type: 'String', desc: 'Who voted.' }
        expose :specialty, documentation: { type: 'String', desc: 'Provider specialty.' }
        expose :region, documentation: { type: 'String', desc: 'Region.' }
        expose :committee_approval_date, documentation: { type: 'String', desc: 'Committee approval date.' }
        expose :assignment_indicator, documentation: { type: 'String', desc: 'Assignment indicator.' }
        expose :orig_synch_date, documentation: { type: 'String', desc: 'Original synchronization date.' }
        expose :review_details, documentation: { type: 'String', desc: 'Details of the review.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
