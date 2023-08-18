class BoardName < ApplicationRecord
	validates :name, presence: true, uniqueness: true
end