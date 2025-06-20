class PracticeLocation < ApplicationRecord
	include PgSearch::Model
	pg_search_scope :search,
                  against: self.column_names,
                  using: {
                    tsearch: {any_word: true}
                  }

  has_many :provider_sources
  has_many :group_engage_providers

	def address = "#{address1} #{address2}"
end
