module Api
  module V1
    class PeerReviews < Grape::API

      helpers do
        params :shared_review_params do
          optional :committee_date, type: DateTime, desc: 'Date of the committee meeting.'
          optional :review_status, type: Integer, desc: 'Status of the review (e.g., 0 for pending, 1 for approved).'
          optional :feedback, type: String, desc: 'Feedback provided during the review.'
        end
      end

      resource :peer_reviews do

        # GET /api/v1/peer_reviews
        desc "Return a list of peer review records"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
          optional :review_status, type: Integer, desc: "Filter by review status."
        end
        get do
          reviews = PeerReview.all
          reviews = reviews.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          reviews = reviews.where(review_status: params[:review_status]) if params[:review_status].present?
          present reviews, with: Api::V1::Entities::PeerReviewEntity
        end

        # POST /api/v1/peer_reviews
        desc "Create a peer review record"
        params do
          use :shared_review_params
          requires :provider_id, type: Integer, desc: 'ID of the reviewed Provider.'
        end
        post do
          review_params = declared(params, include_missing: false)
          review = PeerReview.new(review_params)

          if review.save
            present review, with: Api::V1::Entities::PeerReviewEntity
          else
            error!({ errors: review.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/peer_reviews/:id
          desc "Return a specific peer review record"
          get do
            review = PeerReview.find(params[:id])
            present review, with: Api::V1::Entities::PeerReviewEntity
          end

          # PUT /api/v1/peer_reviews/:id
          desc "Update a peer review record"
          params do
            use :shared_review_params
          end
          put do
            review = PeerReview.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if review.update(update_params)
              present review, with: Api::V1::Entities::PeerReviewEntity
            else
              error!({ errors: review.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/peer_reviews/:id
          desc "Delete a peer review record"
          delete do
            review = PeerReview.find(params[:id])
            if review.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete peer review record"] }, 500)
            end
          end

        end
      end
    end
  end
end
