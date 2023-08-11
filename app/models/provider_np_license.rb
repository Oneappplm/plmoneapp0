class ProviderNpLicense < ApplicationRecord
  belongs_to :provider

  # will refactor this to use relationship instead
  def state
    State.find_by(id: self.state_id)
  rescue
    nil
  end
end
