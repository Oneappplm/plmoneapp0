class EnrollmentComment < ApplicationRecord
  belongs_to :enroll_group, optional: true
  belongs_to :enrollment_provider, optional: true
  belongs_to :provider, optional: true
  belongs_to :user


end