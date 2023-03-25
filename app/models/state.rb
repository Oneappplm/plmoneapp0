class State < ApplicationRecord
	validates_uniqueness_of :name, :alpha_code
end