module Api
  module V1
    module Entities
      class GroupDcoOldLocationAddressEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the old address record.' }
        expose :group_dco_id, documentation: { type: 'Integer', desc: 'ID of the associated GroupDco.' }
        expose :old_address, documentation: { type: 'String', desc: 'The old street address.' }
        expose :old_city, documentation: { type: 'String', desc: 'The old city.' }
        expose :old_state, documentation: { type: 'String', desc: 'The old state.' }
        expose :old_zipcode, documentation: { type: 'String', desc: 'The old zipcode.' }
        expose :old_county, documentation: { type: 'String', desc: 'The old county.' }
        expose :is_old_location_primary, documentation: { type: 'Boolean', desc: 'Flag indicating if this was the primary old location.' }
        expose :effective_date, documentation: { type: 'Date', desc: 'Effective date associated with this old address.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
