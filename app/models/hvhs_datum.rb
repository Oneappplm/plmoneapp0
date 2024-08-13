class HvhsDatum < ApplicationRecord
  include PgSearch::Model

  # Define a pg_search_scope that searches across the full concatenated name
  pg_search_scope :search,
    against: [:first_name, :middle_name, :last_name],
    using: {
      tsearch: {
        prefix: true,
        any_word: true,
        dictionary: "english"
      }
    },
    ignoring: :accents

  # Override the scope to search across concatenated fields
  def self.search(query)
    where("CONCAT_WS(' ', first_name, middle_name, last_name) ILIKE ?", "%#{query}%")
  end

  # Method to return the fullname
  def fullname
    "#{first_name} #{middle_name} #{last_name}".strip
  end
end
