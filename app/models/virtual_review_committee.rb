class VirtualReviewCommittee < ApplicationRecord
	include PgSearch::Model
	pg_search_scope :search,
                  against: self.column_names,
                  using: {
                    tsearch: {any_word: true}
                  }

 enum progress_status: {
		completed: 'Completed',
		assigned: 'Assigned',
		to_be_assigned: 'To Be Assigned'
	}

	def social
		"@#{self.provider_name.parameterize}"
	end
end