class AddUpdatedByToEnrollmentProviders < ActiveRecord::Migration[7.0]
  def change
			add_column :enrollment_providers, :updated_by, :string
  end
end
