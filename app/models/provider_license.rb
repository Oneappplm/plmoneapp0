class ProviderLicense < ApplicationRecord
  belongs_to :provider
  
  def state
    State.find_by(id: self.state_id)
  rescue
    nil
  end
end
