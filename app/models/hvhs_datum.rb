class HvhsDatum < ApplicationRecord
  include PgSearch::Model
	pg_search_scope :search,
          against: self.column_names,
          using: {
            tsearch: {any_word: true}
          } rescue nil

  def fullname = "#{first_name} #{middle_name} #{last_name}"
end
