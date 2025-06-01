module Api
  module V1
    module Entities
      class GroupDcoProviderOutreachInformationEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the outreach info record.' }
        expose :group_dco_id, documentation: { type: 'Integer', desc: 'ID of the associated GroupDco.' }
        expose :name, documentation: { type: 'String', desc: 'Name of the outreach contact.' }
        expose :email, documentation: { type: 'String', desc: 'Email of the outreach contact.' }
        expose :phone, documentation: { type: 'String', desc: 'Phone number of the outreach contact.' }
        expose :fax, documentation: { type: 'String', desc: 'Fax number of the outreach contact.' }
        expose :position, documentation: { type: 'String', desc: 'Position of the outreach contact.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
