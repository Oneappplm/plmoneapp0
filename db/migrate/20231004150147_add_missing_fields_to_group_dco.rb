class AddMissingFieldsToGroupDco < ActiveRecord::Migration[7.0]
  def change
    add_column :group_dcos, :website, :string, if_not_exists: true
    add_column :group_dcos, :telehealth_video_conferencing_technology, :string, if_not_exists: true
    add_column :group_dcos, :tax_id, :string, if_not_exists: true
    add_column :group_dcos, :facility_billing_npi, :string, if_not_exists: true
    add_column :group_dcos, :mn_medicaid_number, :string, if_not_exists: true
    add_column :group_dcos, :wi_medicaid_number, :string, if_not_exists: true
    add_column :group_dcos, :medicare_id_ptan, :string, if_not_exists: true
    add_column :group_dcos, :taxonomy, :string, if_not_exists: true
    add_column :group_dcos, :is_gender_affirming_treatment, :string, if_not_exists: true
    add_column :group_dcos, :panel_size, :string, if_not_exists: true
    add_column :group_dcos, :medicare_authorized_official, :string, if_not_exists: true
    add_column :group_dcos, :collab_name, :string, if_not_exists: true
    add_column :group_dcos, :collab_npi, :string, if_not_exists: true
    add_column :group_dcos, :is_old_location_primary, :string, if_not_exists: true
    add_column :group_dcos, :old_zipcode, :string, if_not_exists: true
    add_column :group_dcos, :old_county, :string, if_not_exists: true
    add_column :group_dcos, :old_state, :string, if_not_exists: true
    add_column :group_dcos, :old_city, :string, if_not_exists: true
    add_column :group_dcos, :old_address, :string, if_not_exists: true
  end
end
