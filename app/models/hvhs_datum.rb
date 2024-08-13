class HvhsDatum < ApplicationRecord
  include PgSearch::Model

  # Define a pg_search_scope that searches across specific columns
  pg_search_scope :search,
    against: [:first_name, :middle_name, :last_name],
    using: {
      tsearch: { prefix: true, any_word: true }
    }

  # Method to return the fullname
  def fullname
    "#{first_name} #{middle_name} #{last_name}".strip
  end
end
