class GroupEngageProvider < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search,
    against: self.column_names,
    using: { tsearch: { any_word: true } }

  belongs_to :practice_location, optional: true
  belongs_to :user, optional: true
  # has_one :provider_source
  has_many :provider_sources, dependent: :destroy


  with_options unless: :system_generated? do
    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email_address, presence: true
    validates :ssn, presence: true
  end

  def system_generated?
    user_id.present? && first_name.blank?
  end

  # after_create :create_provider_source
  # after_create :create_user
  def full_name = [first_name, middle_name, last_name].compact.join(' ')

  # private

  # def create_provider_source
  #   GroupEngageProvider::CreateProviderSourceService.call(self)
  # end

  # def create_user
  #   GroupEngageProvider::CreateUserService.call(self)
  # end
end
