class CreateProviderPersonalInformationSamRvaRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_personal_information_sam_rva_records do |t|
      t.references :provider_personal_information_sam_record, index: false
      t.string     :search_result
      t.string     :exclusion_type
      t.string     :verification_sanctions
      t.string     :comments
      t.datetime   :source_date
      t.datetime   :verification_date
      t.string       :supporting_documentation
      t.timestamps
    end
    add_index  :provider_personal_information_sam_rva_records, :provider_personal_information_sam_record_id, :name => 'ppisrr_sam_rva_record_id'
  end
end
