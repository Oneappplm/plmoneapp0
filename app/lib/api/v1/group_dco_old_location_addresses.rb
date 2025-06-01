module Api
  module V1
    class GroupDcoOldLocationAddresses < Grape::API

      helpers do
        params :shared_old_address_params do
          optional :old_address, type: String, desc: 'The old street address.'
          optional :old_city, type: String, desc: 'The old city.'
          optional :old_state, type: String, desc: 'The old state.'
          optional :old_zipcode, type: String, desc: 'The old zipcode.'
          optional :old_county, type: String, desc: 'The old county.'
          optional :is_old_location_primary, type: Boolean, desc: 'Flag indicating if this was the primary old location.'
          optional :effective_date, type: Date, desc: 'Effective date associated with this old address.'
        end
      end

      resource :group_dco_old_location_addresses do

        # GET /api/v1/group_dco_old_location_addresses
        desc "Return a list of group DCO old location addresses"
        params do
          optional :group_dco_id, type: Integer, desc: "Filter by GroupDco ID."
        end
        get do
          addresses = GroupDcoOldLocationAddress.all
          addresses = addresses.where(group_dco_id: params[:group_dco_id]) if params[:group_dco_id].present?
          present addresses, with: Api::V1::Entities::GroupDcoOldLocationAddressEntity
        end

        # POST /api/v1/group_dco_old_location_addresses
        desc "Create a group DCO old location address"
        params do
          use :shared_old_address_params
          requires :group_dco_id, type: Integer, desc: 'ID of the associated GroupDco.'
        end
        post do
          address_params = declared(params, include_missing: false)
          address = GroupDcoOldLocationAddress.new(address_params)

          if address.save
            present address, with: Api::V1::Entities::GroupDcoOldLocationAddressEntity
          else
            error!({ errors: address.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/group_dco_old_location_addresses/:id
          desc "Return a specific group DCO old location address"
          get do
            address = GroupDcoOldLocationAddress.find(params[:id])
            present address, with: Api::V1::Entities::GroupDcoOldLocationAddressEntity
          end

          # PUT /api/v1/group_dco_old_location_addresses/:id
          desc "Update a group DCO old location address"
          params do
            use :shared_old_address_params
          end
          put do
            address = GroupDcoOldLocationAddress.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if address.update(update_params)
              present address, with: Api::V1::Entities::GroupDcoOldLocationAddressEntity
            else
              error!({ errors: address.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/group_dco_old_location_addresses/:id
          desc "Delete a group DCO old location address"
          delete do
            address = GroupDcoOldLocationAddress.find(params[:id])
            if address.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete group DCO old location address"] }, 500)
            end
          end

        end
      end
    end
  end
end
