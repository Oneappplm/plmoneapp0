module Api
  module V1
    class VirtualReviewCommittees < Grape::API

      helpers do
        params :shared_vrc_params do
          optional :provider_name, type: String, desc: 'Provider name associated with the review.'
          optional :provider_type, type: String, desc: 'Type of the provider.'
          optional :state, type: String, desc: 'State associated with the review.'
          optional :cred_cycle, type: String, desc: 'Credentialing cycle.'
          optional :psv_completed_date, type: DateTime, desc: 'Date PSV was completed.'
          optional :review_level, type: String, desc: 'Level of review.'
          optional :recred_due_date, type: DateTime, desc: 'Recredentialing due date.'
          optional :review_date, type: DateTime, desc: 'Date of review.'
          optional :committee_date, type: DateTime, desc: 'Date committee met.'
          optional :vote_date, type: DateTime, desc: 'Date vote occurred.'
          optional :status, type: String, desc: 'Current status of the review.'
          optional :progress_status, type: String, desc: 'Progress status.'
          optional :client_id, type: Integer, desc: 'Associated Client ID.'
          optional :provider_id, type: Integer, desc: 'Associated Provider ID.'
          optional :provider_cycle_id, type: String, desc: 'Provider cycle ID.'
          optional :medv_id, type: Integer, desc: 'Associated MedV ID.'
          optional :first_name, type: String, desc: 'First name (duplicate of provider?).'
          optional :last_name, type: String, desc: 'Last name (duplicate of provider?).'
          optional :cred_or_recred, type: String, desc: 'Credentialing or recredentialing indicator.'
          optional :app_complete_data, type: String, desc: 'Application complete data/date.'
          optional :voted_by, type: String, desc: 'Who voted.'
          optional :specialty, type: String, desc: 'Provider specialty.'
          optional :region, type: String, desc: 'Region.'
          optional :committee_approval_date, type: String, desc: 'Committee approval date.'
          optional :assignment_indicator, type: String, desc: 'Assignment indicator.'
          optional :orig_synch_date, type: String, desc: 'Original synchronization date.'
          optional :review_details, type: String, desc: 'Details of the review.'
        end
      end

      resource :virtual_review_committees do

        # GET /api/v1/virtual_review_committees
        desc "Return a list of virtual review committee records"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
          optional :client_id, type: Integer, desc: "Filter by Client ID."
          optional :status, type: String, desc: "Filter by status."
        end
        get do
          committees = VirtualReviewCommittee.all
          committees = committees.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          committees = committees.where(client_id: params[:client_id]) if params[:client_id].present?
          committees = committees.where(status: params[:status]) if params[:status].present?
          present committees, with: Api::V1::Entities::VirtualReviewCommitteeEntity
        end

        # POST /api/v1/virtual_review_committees
        desc "Create a virtual review committee record"
        params do
          use :shared_vrc_params
          requires :provider_id
        end
        post do
          committee_params = declared(params, include_missing: false)
          committee = VirtualReviewCommittee.new(committee_params)

          if committee.save
            present committee, with: Api::V1::Entities::VirtualReviewCommitteeEntity
          else
            error!({ errors: committee.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/virtual_review_committees/:id
          desc "Return a specific virtual review committee record"
          get do
            committee = VirtualReviewCommittee.find(params[:id])
            present committee, with: Api::V1::Entities::VirtualReviewCommitteeEntity
          end

          # PUT /api/v1/virtual_review_committees/:id
          desc "Update a virtual review committee record"
          params do
            use :shared_vrc_params
            # IDs like provider_id, client_id are optional if re-assigning allowed
          end
          put do
            committee = VirtualReviewCommittee.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if committee.update(update_params)
              present committee, with: Api::V1::Entities::VirtualReviewCommitteeEntity
            else
              error!({ errors: committee.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/virtual_review_committees/:id
          desc "Delete a virtual review committee record"
          delete do
            committee = VirtualReviewCommittee.find(params[:id])
            if committee.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete virtual review committee record"] }, 500)
            end
          end

        end
      end
    end
  end
end
