class Role < ApplicationRecord
 validates :name, uniqueness: true, presence: true
 before_validation :set_slug, on: :create
	after_create :generate_role_based_access
	after_destroy :delete_role_based_access

	class << self
		def load_data
			['Super Administrator', 'Administrator', 'Admin Staff', 'Calls Agent', 'Agent', 'Encoder'].each do |role|
				find_or_create_by!(name: role)
			end
		end
	end

 private
 def set_slug
  self.slug = name.parameterize(separator: '_')
 end

	def generate_role_based_access
		RoleBasedAccess.initialize_access(slug)
	end

	def delete_role_based_access
		RoleBasedAccess.where(role: slug).destroy_all
	end
end
