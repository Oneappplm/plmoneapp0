class Role < ApplicationRecord
 validates :name, uniqueness: true, presence: true
 before_validation :set_slug, on: :create

	class << self
		def load_data
			['Administrator', 'Calls Agent', 'Encoder'].each do |role|
				find_or_create_by!(name: role)
			end
		end
	end

 private
 def set_slug
  self.slug = name.parameterize(separator: '_')
 end
end
