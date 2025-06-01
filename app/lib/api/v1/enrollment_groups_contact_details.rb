module Api
  module V1
    class EnrollmentGroupsContactDetails < Grape::API

      helpers do
        params :shared_eg_contact_params do
          optional :group_personnel_name, type: String, desc: 'Name of the group personnel.'
          optional :group_personnel_email, type: String, desc: 'Email of the group personnel.'
          optional :group_personnel_phone_number, type: String, desc: 'Phone number of the group personnel.'
          optional :group_personnel_fax_number, type: String, desc: 'Fax number of the group personnel.'
          optional :group_personnel_position, type: String, desc: 'Position of the group personnel.'
        end
      end

      resource :enrollment_groups_contact_details do

        # GET /api/v1/enrollment_groups_contact_details
        desc "Return a list of enrollment group contact details"
        params do
          optional :enrollment_group_id, type: Integer, desc: "Filter by EnrollmentGroup ID."
        end
        get do
          contacts = EnrollmentGroupsContactDetail.all
          contacts = contacts.where(enrollment_group_id: params[:enrollment_group_id]) if params[:enrollment_group_id].present?
          present contacts, with: Api::V1::Entities::EnrollmentGroupsContactDetailEntity
        end

        # POST /api/v1/enrollment_groups_contact_details
        desc "Create an enrollment group contact detail"
        params do
          use :shared_eg_contact_params
          requires :enrollment_group_id, type: Integer, desc: 'ID of the associated EnrollmentGroup.'
        end
        post do
          contact_params = declared(params, include_missing: false)
          contact = EnrollmentGroupsContactDetail.new(contact_params)

          if contact.save
            present contact, with: Api::V1::Entities::EnrollmentGroupsContactDetailEntity
          else
            error!({ errors: contact.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/enrollment_groups_contact_details/:id
          desc "Return a specific enrollment group contact detail"
          get do
            contact = EnrollmentGroupsContactDetail.find(params[:id])
            present contact, with: Api::V1::Entities::EnrollmentGroupsContactDetailEntity
          end

          # PUT /api/v1/enrollment_groups_contact_details/:id
          desc "Update an enrollment group contact detail"
          params do
            use :shared_eg_contact_params
          end
          put do
            contact = EnrollmentGroupsContactDetail.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if contact.update(update_params)
              present contact, with: Api::V1::Entities::EnrollmentGroupsContactDetailEntity
            else
              error!({ errors: contact.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/enrollment_groups_contact_details/:id
          desc "Delete an enrollment group contact detail"
          delete do
            contact = EnrollmentGroupsContactDetail.find(params[:id])
            if contact.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete enrollment group contact detail"] }, 500)
            end
          end

        end
      end
    end
  end
end
