module Api
  module V1
    class PeerRecommendations < Grape::API

      helpers do
        params :shared_recommendation_params do
          optional :allow_recommendation, type: Boolean, desc: 'Flag indicating if recommendation is allowed.'
          optional :recommendation, type: String, desc: 'The recommendation text or status.'
          optional :document, type: String, desc: 'Path/reference to an associated document.'
          optional :notes, type: String, desc: 'Additional notes.'
        end
      end

      resource :peer_recommendations do

        # GET /api/v1/peer_recommendations
        desc "Return a list of peer recommendation records"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
        end
        get do
          recommendations = PeerRecommendation.all
          recommendations = recommendations.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          present recommendations, with: Api::V1::Entities::PeerRecommendationEntity
        end

        # POST /api/v1/peer_recommendations
        desc "Create a peer recommendation record"
        params do
          use :shared_recommendation_params
          requires :provider_id, type: Integer, desc: 'ID of the recommended Provider.'
        end
        post do
          recommendation_params = declared(params, include_missing: false)
          recommendation = PeerRecommendation.new(recommendation_params)

          if recommendation.save
            present recommendation, with: Api::V1::Entities::PeerRecommendationEntity
          else
            error!({ errors: recommendation.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/peer_recommendations/:id
          desc "Return a specific peer recommendation record"
          get do
            recommendation = PeerRecommendation.find(params[:id])
            present recommendation, with: Api::V1::Entities::PeerRecommendationEntity
          end

          # PUT /api/v1/peer_recommendations/:id
          desc "Update a peer recommendation record"
          params do
            use :shared_recommendation_params
          end
          put do
            recommendation = PeerRecommendation.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if recommendation.update(update_params)
              present recommendation, with: Api::V1::Entities::PeerRecommendationEntity
            else
              error!({ errors: recommendation.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/peer_recommendations/:id
          desc "Delete a peer recommendation record"
          delete do
            recommendation = PeerRecommendation.find(params[:id])
            if recommendation.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete peer recommendation record"] }, 500)
            end
          end

        end
      end
    end
  end
end
