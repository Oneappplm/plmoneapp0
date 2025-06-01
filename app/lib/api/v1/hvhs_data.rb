module Api
  module V1
    class HvhsData < Grape::API

      helpers do
        params :shared_hvhs_params do
          optional :npi, type: String, desc: 'NPI number.'
          optional :first_name, type: String, desc: 'First name.'
          optional :middle_name, type: String, desc: 'Middle name.'
          optional :last_name, type: String, desc: 'Last name.'
          optional :degree_titles, type: String, desc: 'Degree titles.'
          optional :office_address_line1, type: String, desc: 'Office address line 1.'
          optional :office_address_line2, type: String, desc: 'Office address line 2.'
          optional :office_city, type: String, desc: 'Office city.'
          optional :office_state, type: String, desc: 'Office state.'
          optional :office_zip_code, type: String, desc: 'Office zip code.'
          optional :phone_number, type: String, desc: 'Phone number.'
          optional :practice_email_address, type: String, desc: 'Practice email address.'
          optional :office_mgr_email, type: String, desc: 'Office manager email.'
          optional :office_mgr_fax, type: String, desc: 'Office manager fax.'
          optional :office_mgr_first_name, type: String, desc: 'Office manager first name.'
          optional :office_mgr_last_name, type: String, desc: 'Office manager last name.'
          optional :office_mgr_phone, type: String, desc: 'Office manager phone.'
          optional :special_type, type: String, desc: 'Special type.'
          optional :taxonomy_code, type: String, desc: 'Taxonomy code.'
          optional :license_number, type: String, desc: 'License number.'
          optional :license_state, type: String, desc: 'License state.'
        end
      end

      resource :hvhs_data do

        # GET /api/v1/hvhs_data
        desc "Return a list of HVHS data records"
        params do
          optional :npi, type: String, desc: "Filter by NPI."
          optional :last_name, type: String, desc: "Filter by last name."
          optional :license_state, type: String, desc: "Filter by license state."
        end
        get do
          data_records = HvhsData.all
          data_records = data_records.where(npi: params[:npi]) if params[:npi].present?
          data_records = data_records.where(last_name: params[:last_name]) if params[:last_name].present?
          data_records = data_records.where(license_state: params[:license_state]) if params[:license_state].present?
          present data_records, with: Api::V1::Entities::HvhsDataEntity
        end

        # POST /api/v1/hvhs_data
        desc "Create an HVHS data record"
        params do
          use :shared_hvhs_params
          requires :npi
          requires :last_name
        end
        post do
          data_params = declared(params, include_missing: false)
          data_record = HvhsData.new(data_params)

          if data_record.save
            present data_record, with: Api::V1::Entities::HvhsDataEntity
          else
            error!({ errors: data_record.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/hvhs_data/:id
          desc "Return a specific HVHS data record"
          get do
            data_record = HvhsData.find(params[:id])
            present data_record, with: Api::V1::Entities::HvhsDataEntity
          end

          # PUT /api/v1/hvhs_data/:id
          desc "Update an HVHS data record"
          params do
            use :shared_hvhs_params
          end
          put do
            data_record = HvhsData.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if data_record.update(update_params)
              present data_record, with: Api::V1::Entities::HvhsDataEntity
            else
              error!({ errors: data_record.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/hvhs_data/:id
          desc "Delete an HVHS data record"
          delete do
            data_record = HvhsData.find(params[:id])
            if data_record.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete HVHS data record"] }, 500)
            end
          end

        end
      end
    end
  end
end
