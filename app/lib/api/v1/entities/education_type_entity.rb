module Api
  module V1
    module Entities
      class EducationTypeEntity < Grape::Entity
        expose :id
        expose :name
        expose :created_at
        expose :updated_at
      end
    end
  end
end
