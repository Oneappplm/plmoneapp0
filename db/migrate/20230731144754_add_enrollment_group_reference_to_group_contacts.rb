class AddEnrollmentGroupReferenceToGroupContacts < ActiveRecord::Migration[7.0]
  def change
    add_reference :group_contacts, :enrollment_group, foreign_key: true
  end
end
