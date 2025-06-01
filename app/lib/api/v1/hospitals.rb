module Api
  module V1
    class Hospitals < Grape::API

      helpers do
        params :shared_hospital_params do
          requires :name, type: String, desc: 'Name of the hospital'
          optional :address, type: String, desc: 'Address of the hospital'
          optional :phone, type: String, desc: 'Contact number of the hospital'
        end
      end

      resource :hospitals do

        # GET /api/v1/hospitals
        desc 'Return all hospitals'
        get do
          hospitals = Hospital.all
          present hospitals, with: Api::V1::Entities::HospitalEntity
        end

        # POST /api/v1/hospitals
        desc 'Create a hospital'
        params do
          use :shared_hospital_params
        end
        post do
          hospital = Hospital.new(declared(params, include_missing: false))

          if hospital.save
            present hospital, with: Api::V1::Entities::HospitalEntity
          else
            error!({ errors: hospital.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/hospitals/:id
          desc 'Return a specific hospital'
          get do
            hospital = Hospital.find(params[:id])
            present hospital, with: Api::V1::Entities::HospitalEntity
          end

          # PUT /api/v1/hospitals/:id
          desc 'Update a hospital'
          params do
            use :shared_hospital_params
          end
          put do
            hospital = Hospital.find(params[:id])
            update_params = declared(params, include_missing: false)

            if hospital.update(update_params)
              present hospital, with: Api::V1::Entities::HospitalEntity
            else
              error!({ errors: hospital.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/hospitals/:id
          desc 'Delete a hospital'
          delete do
            hospital = Hospital.find(params[:id])
            if hospital.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete hospital'] }, 500)
            end
          end

        end
      end
    end
  end
end
