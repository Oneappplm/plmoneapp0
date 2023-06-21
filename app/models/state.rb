class State < ApplicationRecord
	validates_uniqueness_of :name, :alpha_code

  # has_many :providers

  def self.providers_count
    State.select(:alpha_code, :name, :color, 'COUNT(providers.id) AS providers_count').joins(:providers).group(:alpha_code, :name, :color)
  end

  def self.assign_state_color
    # this will be used for the map in overview dashboard
    State.all.each do |state|
      color = SecureRandom.hex(3)
      state.update_attribute('color', "##{color}")
    end
  end
end

