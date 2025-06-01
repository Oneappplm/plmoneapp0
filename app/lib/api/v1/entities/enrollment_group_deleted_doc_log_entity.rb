module Api
  module V1
    module Entities
      class EnrollmentGroupDeletedDocLogEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the log record.' }
        expose :enrollment_group_id, documentation: { type: 'Integer', desc: 'ID of the associated EnrollmentGroup.' }
        expose :document_key, documentation: { type: 'String', desc: 'Key or identifier of the deleted document.' }
        expose :title, documentation: { type: 'String', desc: 'Title of the deleted document.' }
        expose :note, documentation: { type: 'String', desc: 'Note associated with the deletion.' }
        expose :deleted_by, documentation: { type: 'String', desc: 'Identifier of who deleted the document.' }
        expose :deleted_at, documentation: { type: 'DateTime', desc: 'Timestamp when the document was deleted.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp when the log record was created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
