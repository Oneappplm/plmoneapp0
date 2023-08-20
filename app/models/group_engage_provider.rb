class GroupEngageProvider < ApplicationRecord
	include PgSearch::Model
	pg_search_scope :search,
                  against: self.column_names,
                  using: {
                    tsearch: {any_word: true}
                  }

	belongs_to :practice_location, optional: true
	has_one :provider_source

	validates_presence_of :first_name, :last_name, :email_address, :ssn
	validates_uniqueness_of :email_address, :ssn

end
