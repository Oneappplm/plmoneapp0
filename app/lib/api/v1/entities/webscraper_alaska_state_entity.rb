module Api
  module V1
    module Entities
      class WebscraperAlaskaStateEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the Alaska scraped record.' }
        expose :program, documentation: { type: 'String', desc: 'Program name.' }
        expose :license_number, documentation: { type: 'String', desc: 'License number.' }
        expose :dba, documentation: { type: 'String', desc: 'DBA (Doing Business As) name.' }
        expose :owners, documentation: { type: 'String', desc: 'Owners of the entity.' }
        expose :status, documentation: { type: 'String', desc: 'Status of the license/entity.' }
        expose :license_expiration, documentation: { type: 'String', desc: 'License expiration date.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
