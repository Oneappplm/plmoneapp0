class ProvidersPayerLogin < ApplicationRecord
  belongs_to :provider

  has_many :questions, class_name: 'ProvidersPayerLoginsQuestion', dependent: :destroy

  accepts_nested_attributes_for :questions, allow_destroy: true, reject_if: :all_blank

  def state
    State.find_by(id: self.state_id)&.name
  rescue
    ''
  end
end