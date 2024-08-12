class ManageClientsController < ApplicationController

	def index
    @practitioners = Practitioner.paginate(per_page: 10, page: params[:page] || 1)
    @client_organizations = ClientOrganization.paginate(per_page: 10, page: params[:page] || 1)
  end

end

