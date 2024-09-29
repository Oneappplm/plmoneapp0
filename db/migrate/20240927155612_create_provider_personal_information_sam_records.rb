class CreateProviderPersonalInformationSamRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_personal_information_sam_records do |t|
      t.references :provider_personal_information, index: false
      t.string     :name_type
      t.string     :first_name
      t.string     :middle_name
      t.string     :last_name
      t.string     :suffix
      t.string     :ssn

      t.timestamps
    end
    add_index  :provider_personal_information_sam_records, :provider_personal_information_id, :name => 'ppiid_sam_records'
  end
end
