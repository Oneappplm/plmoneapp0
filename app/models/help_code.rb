class HelpCode < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search_by_category_and_code,
                  against: [:category, :code],
                  using: {
                    tsearch: { prefix: true }
                  }
                  
  enum category: {
    "Provider Type Codes": "Provider Type Codes",
    "License Codes": "License Codes",
    "Language Codes": "Language Codes",
    "Country Codes": "Country Codes"
  }
end
