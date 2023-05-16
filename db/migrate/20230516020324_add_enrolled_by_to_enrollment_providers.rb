class AddEnrolledByToEnrollmentProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_providers, :enrolled_by, :string
  end
end
