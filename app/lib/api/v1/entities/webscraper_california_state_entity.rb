module Api
  module V1
    module Entities
      class WebscraperCaliforniaStateEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the California scraped record.' }
        expose :name, documentation: { type: 'String', desc: 'Name of the entity/individual.' }
        expose :license_number, documentation: { type: 'String', desc: 'License number.' }
        expose :license_type, documentation: { type: 'String', desc: 'Type of license.' }
        expose :license_status, documentation: { type: 'String', desc: 'Status of the license.' }
        expose :license_expiration, documentation: { type: 'String', desc: 'License expiration date.' }
        expose :secondary_status, documentation: { type: 'String', desc: 'Secondary status.' }
        expose :city, documentation: { type: 'String', desc: 'City.' }
        expose :state, documentation: { type: 'String', desc: 'State.' }
        expose :county, documentation: { type: 'String', desc: 'County.' }
        expose :zip, documentation: { type: 'String', desc: 'Zip code.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
