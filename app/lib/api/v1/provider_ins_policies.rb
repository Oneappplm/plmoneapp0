module Api
  module V1
    class ProviderInsPolicies < Grape::API

      helpers do
        params :shared_ins_policy_params do
          optional :ins_policy_number, type: String, desc: 'Insurance policy number.'
          optional :effective_date, type: DateTime, desc: 'Policy effective date.'
          optional :expiration_date, type: DateTime, desc: 'Policy expiration date.'
        end
      end

      resource :provider_ins_policies do

        # GET /api/v1/provider_ins_policies
        desc "Return a list of provider insurance policies"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
        end
        get do
          policies = ProviderInsPolicy.all
          policies = policies.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          present policies, with: Api::V1::Entities::ProviderInsPolicyEntity
        end

        # POST /api/v1/provider_ins_policies
        desc "Create a provider insurance policy record"
        params do
          use :shared_ins_policy_params
          requires :provider_id, type: Integer, desc: 'ID of the associated Provider.'
        end
        post do
          policy_params = declared(params, include_missing: false)
          policy = ProviderInsPolicy.new(policy_params)

          if policy.save
            present policy, with: Api::V1::Entities::ProviderInsPolicyEntity
          else
            error!({ errors: policy.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_ins_policies/:id
          desc "Return a specific provider insurance policy record"
          get do
            policy = ProviderInsPolicy.find(params[:id])
            present policy, with: Api::V1::Entities::ProviderInsPolicyEntity
          end

          # PUT /api/v1/provider_ins_policies/:id
          desc "Update a provider insurance policy record"
          params do
            use :shared_ins_policy_params
          end
          put do
            policy = ProviderInsPolicy.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if policy.update(update_params)
              present policy, with: Api::V1::Entities::ProviderInsPolicyEntity
            else
              error!({ errors: policy.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_ins_policies/:id
          desc "Delete a provider insurance policy record"
          delete do
            policy = ProviderInsPolicy.find(params[:id])
            if policy.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider insurance policy record"] }, 500)
            end
          end

        end
      end
    end
  end
end
