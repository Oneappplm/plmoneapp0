class Role < ApplicationRecord
  validates :name, uniqueness: true, presence: true
  before_validation :set_slug, on: :create
	before_validation :strip_whitespace, only: [:name],	on: :create
	after_create :generate_role_based_access
	after_destroy :delete_role_based_access

	has_many :role_based_access, class_name: 'RoleBasedAccess', foreign_key: 'role', primary_key: 'slug', dependent: :destroy

	class << self
		def load_data
			['Super Administrator', 'Administrator', 'Admin Staff', 'Calls Agent', 'Agent', 'Encoder', 'Director', 'Productivity Manager'].each do |role|
				find_or_create_by!(name: role)
			end
		end

		def update_name_remove_whitespace
			all.each do |role|
				role.update_attribute(:name, role.name.strip)
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

	def strip_whitespace
		self.name = name.strip
	end
end
