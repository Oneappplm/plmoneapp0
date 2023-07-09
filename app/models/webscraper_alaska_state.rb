class WebscraperAlaskaState < ApplicationRecord
	include PgSearch::Model
	pg_search_scope :search,
          against: self.column_names,
          using: {
            tsearch: {any_word: true}
          }
end
