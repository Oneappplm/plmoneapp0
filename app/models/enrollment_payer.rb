class EnrollmentPayer < ApplicationRecord
	validates :name, presence: true, uniqueness: true
end