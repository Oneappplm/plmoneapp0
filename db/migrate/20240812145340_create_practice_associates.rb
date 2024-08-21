class CreatePracticeAssociates < ActiveRecord::Migration[7.0]
  def self.up
    create_table :practice_associates, id: false do |t|
      t.primary_key   :provider_practice_associate_id
      t.references    :provider_attest
      t.string        :associate_first_name
      t.string        :associate_last_name
      t.string        :associate_middle_initial
      t.string        :address
      t.string        :address2
      t.string        :city
      t.string        :state
      t.string        :zip
      t.string        :county
      t.string        :phone_number
      t.string        :fax_number
      t.string        :email_address
      t.string        :license_number
      t.string        :license_state
      t.string        :hospital_department_name
      t.string        :check_payable_to
      t.boolean       :electronic_billing_flag
      t.boolean       :coverage_flag
      t.string        :billing_company
      t.string        :coverage_arrangement_explanation
      t.string        :tax_id
      t.string        :other_skills
      t.string        :emergency_phone_number
      t.string        :answering_service_phone_number
      t.string        :title
      t.string        :tax_id_name
      t.string        :phone_extension
      t.string        :degree_degree_abbreviation
      t.string        :provider_type_provider_type_abbreviation
      t.string        :associate_type_associate_type_description

      t.timestamps
    end

    add_column :practice_associates, :provider_practice_id, :integer
    add_index  :practice_associates, :provider_practice_id
  end

  def self.down
    drop_table :practice_associates
  end
end
