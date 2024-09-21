class PeerRecommendationsController < ApplicationController
  before_action :set_provider, :allow_access
  before_action :set_peer_recommendation, only: [:update, :destroy]


  def index
    @peer_recommendations = @provider.peer_recommendations.order(created_at: :desc)
  end

  def create
    peer_recommendation = @provider.peer_recommendations.new(peer_recommendations_params)
    notice = peer_recommendation.save ? 'Peer recommendation was successfully added.' : 'Something went wrong'
    redirect_to provider_peer_recommendations_path(@provider), notice: notice
  end

  def update
    notice = @peer_recommendation.update(peer_recommendations_params) ? 'Peer recommendation was successfully updated.' : 'Something went wrong'
    redirect_to provider_peer_recommendations_path(@provider), notice: notice
  end

  def destroy
    notice = @peer_recommendation.destroy ? 'Peer recommendation was successfully deleted.' : 'Something went wrong'
    redirect_to provider_peer_recommendations_path(@provider), notice: notice
  end 

  private

  def peer_recommendations_params
    params.require(:peer_recommendation).permit(:allow_recommendation, :recommendation, :document, :notes)
  end

  def set_provider
    @provider = Provider.find(params[:provider_id])
    
    redirect_to providers_path unless @provider
  end

  def set_peer_recommendation
    @peer_recommendation = PeerRecommendation.find_by(id: params[:id])

    redirect_to provider_peer_recommendations_path(@provider) unless @peer_recommendation
  end

  def allow_access
    # Only allow admin and director users to access this actions
    redirect_to root_path unless allowed_to_access_peer_recommendations?
  end
end
