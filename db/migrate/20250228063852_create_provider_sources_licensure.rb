class CreateProviderSourcesLicensure < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_sources_licensure do |t|
      t.bigint :provider_source_id, null: false  # Association to provider_source
      t.string  :licensure_state              # From the dropdown for licensure state
      t.string  :license_type                 # From the select for license type
      t.string  :license_number               # From the License Number input
      t.string  :license_status               # From the License Status input
      t.date    :licensure_issue_date         # From the Issue Date input
      t.date    :licensure_expiration_date    # From the Expiration Date input
      t.boolean :licensure_not_expire, default: false  # From the "Does not expire" checkbox
      t.boolean :licensure_practice_state     # From the radio for practicing in state
      t.boolean :licensure_primary_license    # From the radio for primary license
      t.boolean :licensure_require_supervision  # From the radio for supervision requirement
      
      # Sponsor details (only applicable if supervision is required)
      t.string  :licensure_sponsor_fname
      t.string  :licensure_sponsor_mname
      t.string  :licensure_sponsor_lname
      t.string  :licensure_sponsor_suffix
      t.string  :licensure_sponsor_degree

      t.timestamps null: false
    end
    add_index :provider_sources_licensure, :provider_source_id, name: "index_provider_sources_licensure_on_provider_source_id"
  end
end
