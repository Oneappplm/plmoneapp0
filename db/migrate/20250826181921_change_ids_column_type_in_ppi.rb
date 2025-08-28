class ChangeIdsColumnTypeInPpi < ActiveRecord::Migration[7.0]
  def up
    change_column :provider_personal_informations, :caqh_provider_id, 'varchar USING caqh_provider_id::varchar'
    change_column :provider_personal_informations, :provider_attest_id, 'varchar USING provider_attest_id::varchar'
    change_column :provider_personal_informations, :caqh_provider_attest_id, 'varchar USING caqh_provider_attest_id::varchar'
    change_column :provider_attests, :caqh_provider_attest_id, 'varchar USING caqh_provider_attest_id::varchar'
  end

  def down
    change_column :provider_personal_informations, :caqh_provider_id, 'integer USING caqh_provider_id::integer'
    change_column :provider_personal_informations, :provider_attest_id, 'integer USING provider_attest_id::integer'
    change_column :provider_personal_informations, :caqh_provider_attest_id, 'integer USING caqh_provider_attest_id::integer'
    change_column :provider_attests, :caqh_provider_attest_id, 'integer USING caqh_provider_attest_id::integer'
  end
end
