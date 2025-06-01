module Api
  module V1
    class GroupDcos < Grape::API

      helpers do
        params :shared_group_dco_params do
          optional :client, type: String, desc: 'Client name/identifier.'
          optional :dco_name, type: String, desc: 'DCO name.'
          optional :dco_address, type: String, desc: 'DCO address.'
          optional :dco_city, type: String, desc: 'DCO city.'
          optional :state, type: String, desc: 'DCO state.'
          optional :dco_zipcode, type: String, desc: 'DCO zipcode.'
          optional :county, type: String, desc: 'DCO county.'
          optional :service_location_phone_number, type: String, desc: 'Service location phone number.'
          optional :service_location_fax_number, type: String, desc: 'Service location fax number.'
          optional :panel_status_to_new_patients, type: String, desc: 'Panel status for new patients.'
          optional :panel_age_limit, type: String, desc: 'Panel age limit.'
          optional :include_in_directory, type: String, desc: 'Include in directory status.'
          optional :dco_provider_name, type: String, desc: 'DCO provider contact name.'
          optional :dco_provider_email, type: String, desc: 'DCO provider contact email.'
          optional :dco_provider_phone_number, type: String, desc: 'DCO provider contact phone.'
          optional :dco_provider_fax_number, type: String, desc: 'DCO provider contact fax.'
          optional :dco_provider_position, type: String, desc: 'DCO provider contact position.'
          optional :inpatient_facility, type: String, desc: 'Inpatient facility status.'
          optional :is_clinic, type: String, desc: 'Is clinic status.'
          optional :telehealth_provider, type: String, desc: 'Telehealth provider status.'
          optional :old_address, type: String, desc: 'Old address.'
          optional :old_city, type: String, desc: 'Old city.'
          optional :old_state, type: String, desc: 'Old state.'
          optional :old_county, type: String, desc: 'Old county.'
          optional :old_zipcode, type: String, desc: 'Old zipcode.'
          optional :is_old_location_primary, type: Boolean, desc: 'Was old location primary?'
          optional :website, type: String, desc: 'Website URL.'
          optional :tax_id, type: String, desc: 'Tax ID.'
          optional :facility_billing_npi, type: String, desc: 'Facility billing NPI.'
          optional :mn_medicaid_number, type: String, desc: 'MN Medicaid number.'
          optional :wi_medicaid_number, type: String, desc: 'WI Medicaid number.'
          optional :medicare_id_ptan, type: String, desc: 'Medicare ID/PTAN.'
          optional :taxonomy, type: String, desc: 'Taxonomy code.'
          optional :telehealth_video_conferencing_technology, type: String, desc: 'Telehealth video technology.'
          optional :is_gender_affirming_treatment, type: String, desc: 'Provides gender affirming treatment status.'
          optional :panel_size, type: String, desc: 'Panel size.'
          optional :medicare_authorized_official, type: String, desc: 'Medicare authorized official.'
          optional :collab_name, type: String, desc: 'Collaborator name.'
          optional :collab_npi, type: String, desc: 'Collaborator NPI.'
          optional :is_primary_location, type: Boolean, desc: 'Is this the primary location?'
          optional :effective_date, type: Date, desc: 'Effective date.'
          optional :location_status, type: String, desc: 'Location status.'
          optional :location_npi, type: String, desc: 'Location NPI.'
          optional :location_tin, type: String, desc: 'Location TIN.'
          optional :npi_digits, type: String, desc: 'NPI digits info.'
          optional :tin_digits_type, type: String, desc: 'TIN digits type.'
          optional :specialty, type: String, desc: 'Specialty.'
        end
      end

      resource :group_dcos do

        # GET /api/v1/group_dcos
        desc "Return a list of group DCO records"
        params do
          optional :enrollment_group_id, type: Integer, desc: "Filter by Enrollment Group ID."
          optional :dco_name, type: String, desc: "Filter by DCO name."
          optional :state, type: String, desc: "Filter by state."
        end
        get do
          group_dcos = GroupDco.all
          group_dcos = group_dcos.where(enrollment_group_id: params[:enrollment_group_id]) if params[:enrollment_group_id].present?
          group_dcos = group_dcos.where(dco_name: params[:dco_name]) if params[:dco_name].present?
          group_dcos = group_dcos.where(state: params[:state]) if params[:state].present?
          present group_dcos, with: Api::V1::Entities::GroupDcoEntity
        end

        # POST /api/v1/group_dcos
        desc "Create a group DCO record"
        params do
          use :shared_group_dco_params
          requires :enrollment_group_id, type: Integer, desc: 'ID of the associated Enrollment Group.'
        end
        post do
          group_dco_params = declared(params, include_missing: false)
          group_dco = GroupDco.new(group_dco_params)

          if group_dco.save
            present group_dco, with: Api::V1::Entities::GroupDcoEntity
          else
            error!({ errors: group_dco.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/group_dcos/:id
          desc "Return a specific group DCO record"
          get do
            group_dco = GroupDco.find(params[:id])
            present group_dco, with: Api::V1::Entities::GroupDcoEntity
          end

          # PUT /api/v1/group_dcos/:id
          desc "Update a group DCO record"
          params do
            use :shared_group_dco_params
          end
          put do
            group_dco = GroupDco.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if group_dco.update(update_params)
              present group_dco, with: Api::V1::Entities::GroupDcoEntity
            else
              error!({ errors: group_dco.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/group_dcos/:id
          desc "Delete a group DCO record"
          delete do
            group_dco = GroupDco.find(params[:id])
            if group_dco.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete group DCO record"] }, 500)
            end
          end

        end
      end
    end
  end
end
