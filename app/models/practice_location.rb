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


  validates :location, :address1, :city, :state_id, :zip_code, :phone_number, :email, :group_tax_number, presence: true  
  validates :email, presence: true, uniqueness: true, 
                    format: { with: /\A[^@\s]+@[^@\s]+\z/, message: "must be a valid email format" }
end
