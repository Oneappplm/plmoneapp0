module Api
  module V1
    class GroupDcoNotes < Grape::API

      helpers do
        params :shared_dco_note_params do
          optional :title, type: String, desc: 'Title of the note.'
          optional :description, type: String, desc: 'Content/description of the note.'
        end
      end

      resource :group_dco_notes do

        # GET /api/v1/group_dco_notes
        desc "Return a list of group DCO notes"
        params do
          optional :group_dco_id, type: Integer, desc: "Filter by GroupDco ID."
        end
        get do
          notes = GroupDcoNote.all
          notes = notes.where(group_dco_id: params[:group_dco_id]) if params[:group_dco_id].present?
          present notes, with: Api::V1::Entities::GroupDcoNoteEntity
        end

        # POST /api/v1/group_dco_notes
        desc "Create a group DCO note"
        params do
          use :shared_dco_note_params
          requires :group_dco_id, type: Integer, desc: 'ID of the associated GroupDco.'
          requires :title
          requires :description
        end
        post do
          note_params = declared(params, include_missing: false)
          note = GroupDcoNote.new(note_params)

          if note.save
            present note, with: Api::V1::Entities::GroupDcoNoteEntity
          else
            error!({ errors: note.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/group_dco_notes/:id
          desc "Return a specific group DCO note"
          get do
            note = GroupDcoNote.find(params[:id])
            present note, with: Api::V1::Entities::GroupDcoNoteEntity
          end

          # PUT /api/v1/group_dco_notes/:id
          desc "Update a group DCO note"
          params do
            use :shared_dco_note_params
          end
          put do
            note = GroupDcoNote.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if note.update(update_params)
              present note, with: Api::V1::Entities::GroupDcoNoteEntity
            else
              error!({ errors: note.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/group_dco_notes/:id
          desc "Delete a group DCO note"
          delete do
            note = GroupDcoNote.find(params[:id])
            if note.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete group DCO note"] }, 500)
            end
          end

        end
      end
    end
  end
end
