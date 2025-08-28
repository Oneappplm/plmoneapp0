class CreatePracticeInformationEducations < ActiveRecord::Migration[7.0]
  def change
    create_table :practice_information_educations do |t|
      t.references :provider_attest
      t.integer :caqh_provider_attest_id
      t.string     :institution_name
      t.string     :address
      t.string     :address2
      t.string     :city
      t.string     :county
      t.string     :province
      t.string     :postal_code
      t.string     :country
      t.string     :state
      t.string     :phone_number
      t.string     :email_address
      t.string     :fax_number
      t.string     :program_title
      t.string     :degree_degree_abbreviation
      t.string     :incomplete_explanation
      t.boolean    :program_completed_flag
      t.datetime   :start_date
      t.datetime   :end_date
      t.timestamps
    end
  end
end
