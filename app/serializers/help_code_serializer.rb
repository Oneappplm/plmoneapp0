class HelpCodeSerializer < ActiveModel::Serializer
  attributes :id, :category, :code, :description
end
