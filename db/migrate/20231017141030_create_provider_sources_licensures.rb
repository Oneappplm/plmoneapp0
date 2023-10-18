class CreateProviderSourcesLicensures < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_sources_licensures do |t|
      t.references :provider_source
      t.string :license_type
      t.string :license_status
      t.string :license_number
      t.string :licensure_issue_date
      t.string :licensure_expiration_date
      t.string :licensure_not_expire
      t.string :licensure_practice_state
      t.string :licensure_primary_license
      t.string :licensure_require_supervision
      t.string :licensure_sponsor_degree
      t.string :licensure_sponsor_fname
      t.string :licensure_sponsor_mname
      t.string :licensure_sponsor_lname
      t.string :licensure_sponsor_suffix
      t.timestamps
    end
  end
end
