class AddFieldsToPracticeInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :practice_informations, :caqh_provider_practice_id, :integer if !column_exists?(:practice_informations, :caqh_provider_practice_id)
    add_column :practice_informations, :caqh_provider_attest_id, :integer if !column_exists?(:practice_informations, :caqh_provider_attest_id)
  end
end
