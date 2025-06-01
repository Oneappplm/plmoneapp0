module Api
  module V1
    class HealthPlans < Grape::API

      helpers do
        params :shared_health_plan_params do
          requires :name, type: String, desc: 'Name of the health plan'
        end
      end

      resource :health_plans do

        # GET /api/v1/health_plans
        desc 'Return all health plans'
        get do
          health_plans = HealthPlan.all
          present health_plans, with: Api::V1::Entities::HealthPlanEntity
        end

        # POST /api/v1/health_plans
        desc 'Create a health plan'
        params do
          use :shared_health_plan_params
        end
        post do
          health_plan = HealthPlan.new(declared(params, include_missing: false))

          if health_plan.save
            present health_plan, with: Api::V1::Entities::HealthPlanEntity
          else
            error!({ errors: health_plan.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/health_plans/:id
          desc 'Return a specific health plan'
          get do
            health_plan = HealthPlan.find(params[:id])
            present health_plan, with: Api::V1::Entities::HealthPlanEntity
          end

          # PUT /api/v1/health_plans/:id
          desc 'Update a health plan'
          params do
            use :shared_health_plan_params
          end
          put do
            health_plan = HealthPlan.find(params[:id])
            update_params = declared(params, include_missing: false)

            if health_plan.update(update_params)
              present health_plan, with: Api::V1::Entities::HealthPlanEntity
            else
              error!({ errors: health_plan.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/health_plans/:id
          desc 'Delete a health plan'
          delete do
            health_plan = HealthPlan.find(params[:id])
            if health_plan.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete health plan'] }, 500)
            end
          end

        end
      end
    end
  end
end
