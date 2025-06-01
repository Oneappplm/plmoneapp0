module Api
  module V1
    class GroupDcoProviderOutreachInformations < Grape::API

      helpers do
        params :shared_outreach_params do
          optional :name, type: String, desc: 'Name of the outreach contact.'
          optional :email, type: String, desc: 'Email of the outreach contact.'
          optional :phone, type: String, desc: 'Phone number of the outreach contact.'
          optional :fax, type: String, desc: 'Fax number of the outreach contact.'
          optional :position, type: String, desc: 'Position of the outreach contact.'
        end
      end

      resource :group_dco_provider_outreach_informations do

        # GET /api/v1/group_dco_provider_outreach_informations
        desc "Return a list of group DCO provider outreach information records"
        params do
          optional :group_dco_id, type: Integer, desc: "Filter by GroupDco ID."
        end
        get do
          outreach_infos = GroupDcoProviderOutreachInformation.all
          outreach_infos = outreach_infos.where(group_dco_id: params[:group_dco_id]) if params[:group_dco_id].present?
          present outreach_infos, with: Api::V1::Entities::GroupDcoProviderOutreachInformationEntity
        end

        # POST /api/v1/group_dco_provider_outreach_informations
        desc "Create a group DCO provider outreach information record"
        params do
          use :shared_outreach_params
          requires :group_dco_id, type: Integer, desc: 'ID of the associated GroupDco.'
        end
        post do
          outreach_params = declared(params, include_missing: false)
          outreach_info = GroupDcoProviderOutreachInformation.new(outreach_params)

          if outreach_info.save
            present outreach_info, with: Api::V1::Entities::GroupDcoProviderOutreachInformationEntity
          else
            error!({ errors: outreach_info.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/group_dco_provider_outreach_informations/:id
          desc "Return a specific group DCO provider outreach information record"
          get do
            outreach_info = GroupDcoProviderOutreachInformation.find(params[:id])
            present outreach_info, with: Api::V1::Entities::GroupDcoProviderOutreachInformationEntity
          end

          # PUT /api/v1/group_dco_provider_outreach_informations/:id
          desc "Update a group DCO provider outreach information record"
          params do
            use :shared_outreach_params
          end
          put do
            outreach_info = GroupDcoProviderOutreachInformation.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if outreach_info.update(update_params)
              present outreach_info, with: Api::V1::Entities::GroupDcoProviderOutreachInformationEntity
            else
              error!({ errors: outreach_info.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/group_dco_provider_outreach_informations/:id
          desc "Delete a group DCO provider outreach information record"
          delete do
            outreach_info = GroupDcoProviderOutreachInformation.find(params[:id])
            if outreach_info.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete group DCO provider outreach information record"] }, 500)
            end
          end

        end
      end
    end
  end
end
