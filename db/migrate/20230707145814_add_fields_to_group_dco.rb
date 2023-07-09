class AddFieldsToGroupDco < ActiveRecord::Migration[7.0]
  def up
    add_column :group_dcos, :website, :string
    add_column :group_dcos, :tax_id, :string
    add_column :group_dcos, :facility_billing_npi, :string
    add_column :group_dcos, :mn_medicaid_number, :string
    add_column :group_dcos, :wi_medicaid_number, :string
    add_column :group_dcos, :medicare_id_ptan, :string
    add_column :group_dcos, :taxonomy, :string
    add_column :group_dcos, :telehealth_video_conferencing_technology, :string
    add_column :group_dcos, :is_gender_affirming_treatment, :string
    add_column :group_dcos, :panel_size, :string
    add_column :group_dcos, :is_medicare_authorized, :string
  end

  def down
    remove_column :group_dcos, :website, :string
    remove_column :group_dcos, :tax_id, :string
    remove_column :group_dcos, :facility_billing_npi, :string
    remove_column :group_dcos, :mn_medicaid_number, :string
    remove_column :group_dcos, :wi_medicaid_number, :string
    remove_column :group_dcos, :medicare_id_ptan, :string
    remove_column :group_dcos, :taxonomy, :string
    remove_column :group_dcos, :telehealth_video_conferencing_technology, :string
    remove_column :group_dcos, :is_gender_affirming_treatment, :string
    remove_column :group_dcos, :panel_size, :string
    remove_column :group_dcos, :is_medicare_authorized, :string
  end
end
