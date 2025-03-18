class UsersEnrollmentGroup < ApplicationRecord
  belongs_to :user
  belongs_to :enrollment_group
end
