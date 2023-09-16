class GroupEngageProvider < ApplicationRecord
	include PgSearch::Model
	pg_search_scope :search,
                  against: self.column_names,
                  using: {
                    tsearch: {any_word: true}
                  }

	belongs_to :practice_location, optional: true
	belongs_to :user, optional: true
	has_many	:provider_sources,	dependent: :destroy

	validates_presence_of :first_name, :last_name, :email_address, :ssn
	validates_uniqueness_of :email_address, :ssn

	after_create	:create_provider_source
	after_create :create_user

	def full_name = [first_name, middle_name, last_name].compact.join(' ')

	def create_provider_source
		GroupEngageProvider::CreateProviderSourceService.call(self)
	end

	def create_user
		GroupEngageProvider::CreateUserService.call(self)
	end
end
