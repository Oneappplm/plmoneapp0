class EnrollmentGroupsDetail < ApplicationRecord
  belongs_to :enrollment_group

  def full_name
    "#{self.individual_ownership_first_name} #{self.individual_ownership_last_name}"
  end

  def selected_group_roles
    self.group_role? ? self.group_role.split(',') : ''
  rescue
    ''
  end
end