class CreateProviderInsuranceCoverages < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_insurance_coverages, id: false do |t|
      t.primary_key      :provider_insurance_id
      t.references       :provider_attest
      t.string           :insurance_carrier_name
      t.datetime         :original_start_date
      t.datetime         :start_date
      t.datetime         :end_date
      t.boolean          :self_insured_flag
      t.string           :address
      t.string           :address2
      t.string           :city
      t.string           :state
      t.string           :province
      t.string           :postal_code
      t.string           :phone_number
      t.string           :policy_number
      t.boolean          :individual_coverage_flag
      t.string           :coverage_amount_occurrence
      t.string           :coverage_amount_aggregate
      t.string           :agent_last_name
      t.string           :agent_first_name
      t.string           :policy_holder
      t.boolean          :no_malpractice_claims_flag
      t.datetime         :retroactive_date
      t.boolean          :tail_nose_coverage_flag
      t.text             :tail_nose_coverage_explanation
      t.string           :time_with_carrier
      t.boolean          :coverage_limit_exceeded_flag
      t.boolean          :unlimited_coverage_flag
      t.string           :fax_number
      t.string           :website
      t.boolean          :renewal_date
      t.string           :agent_address
      t.string           :agent_address2
      t.string           :agent_city
      t.string           :agent_state
      t.string           :agent_postal_code
      t.string           :agent_province
      t.text             :surcharge_explanation
      t.string           :excess_coverage_amount
      t.string           :phone_extension
      t.string           :underwriter_name
      t.string           :affiliated_organization_name
      t.string           :agent_country_country_name
      t.string           :country_country_name
      t.text             :insurance_type_insurance_type_description
      t.text             :insurance_coverage_type_insurance_coverage_type_description

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_insurance_coverages
  end
end
