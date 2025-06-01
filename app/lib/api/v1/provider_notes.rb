module Api
  module V1
    class ProviderNotes < Grape::API

      helpers do
        params :shared_note_params do
          optional :title, type: String, desc: 'Title of the note.'
          optional :description, type: String, desc: 'Content/description of the note.'
        end
      end

      resource :provider_notes do

        # GET /api/v1/provider_notes
        desc "Return a list of provider notes"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
        end
        get do
          notes = ProviderNote.all
          notes = notes.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          present notes, with: Api::V1::Entities::ProviderNoteEntity
        end

        # POST /api/v1/provider_notes
        desc "Create a provider note"
        params do
          use :shared_note_params
          requires :provider_id, type: Integer, desc: 'ID of the associated Provider.'
          requires :title
          requires :description
        end
        post do
          note_params = declared(params, include_missing: false)
          note = ProviderNote.new(note_params)

          if note.save
            present note, with: Api::V1::Entities::ProviderNoteEntity
          else
            error!({ errors: note.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_notes/:id
          desc "Return a specific provider note"
          get do
            note = ProviderNote.find(params[:id])
            present note, with: Api::V1::Entities::ProviderNoteEntity
          end

          # PUT /api/v1/provider_notes/:id
          desc "Update a provider note"
          params do
            use :shared_note_params
            optional :provider_id, type: Integer, desc: 'ID of the associated Provider.'
          end
          put do
            note = ProviderNote.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if note.update(update_params)
              present note, with: Api::V1::Entities::ProviderNoteEntity
            else
              error!({ errors: note.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_notes/:id
          desc "Delete a provider note"
          delete do
            note = ProviderNote.find(params[:id])
            if note.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider note"] }, 500)
            end
          end

        end
      end
    end
  end
end
