class AddNewFieldToEnrollmentClients < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_groups, :flatform, :string
  end
end
