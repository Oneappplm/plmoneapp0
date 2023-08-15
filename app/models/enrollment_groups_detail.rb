class EnrollmentGroupsDetail < ApplicationRecord
  belongs_to :enrollment_group

  def full_name
    "#{self.individual_ownership_first_name} #{self.individual_ownership_last_name}"
  end
end