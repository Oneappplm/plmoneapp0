class ChangeDefaultStatusEnrollmentProviders < ActiveRecord::Migration[7.0]
  def up
    change_column_default :enrollment_providers, :status, 'pending'
  end

  def down
    change_column_default :enrollment_providers, :status, nil
  end
end