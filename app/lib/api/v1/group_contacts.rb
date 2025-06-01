module Api
  module V1
    class GroupContacts < Grape::API

      helpers do
        params :shared_contact_params do
          optional :department, type: String, desc: 'Department of the contact.'
          optional :name, type: String, desc: 'Name of the contact.'
          optional :role, type: String, desc: 'Role of the contact.'
          optional :phone, type: String, desc: 'Phone number of the contact.'
          optional :email, type: String, desc: 'Email address of the contact.'
        end
      end

      resource :group_contacts do

        # GET /api/v1/group_contacts
        desc "Return a list of group contacts"
        params do
          optional :group_dco_id, type: Integer, desc: "Filter by GroupDco ID."
          optional :enrollment_group_id, type: Integer, desc: "Filter by EnrollmentGroup ID."
          optional :department, type: String, desc: "Filter by department."
        end
        get do
          contacts = GroupContact.all
          contacts = contacts.where(group_dco_id: params[:group_dco_id]) if params[:group_dco_id].present?
          contacts = contacts.where(enrollment_group_id: params[:enrollment_group_id]) if params[:enrollment_group_id].present?
          contacts = contacts.where(department: params[:department]) if params[:department].present?
          present contacts, with: Api::V1::Entities::GroupContactEntity
        end

        # POST /api/v1/group_contacts
        desc "Create a group contact"
        params do
          use :shared_contact_params
          optional :group_dco_id, type: Integer, desc: 'ID of the associated GroupDco.'
          optional :enrollment_group_id, type: Integer, desc: 'ID of the associated EnrollmentGroup.'
        end
        post do
          contact_params = declared(params, include_missing: false)
          contact = GroupContact.new(contact_params)

          if contact.save
            present contact, with: Api::V1::Entities::GroupContactEntity
          else
            error!({ errors: contact.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/group_contacts/:id
          desc "Return a specific group contact"
          get do
            contact = GroupContact.find(params[:id])
            present contact, with: Api::V1::Entities::GroupContactEntity
          end

          # PUT /api/v1/group_contacts/:id
          desc "Update a group contact"
          params do
            use :shared_contact_params
          end
          put do
            contact = GroupContact.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if contact.update(update_params)
              present contact, with: Api::V1::Entities::GroupContactEntity
            else
              error!({ errors: contact.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/group_contacts/:id
          desc "Delete a group contact"
          delete do
            contact = GroupContact.find(params[:id])
            if contact.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete group contact"] }, 500)
            end
          end

        end
      end
    end
  end
end
