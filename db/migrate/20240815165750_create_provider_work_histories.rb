class CreateProviderWorkHistories < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_work_histories, primary_key: [:provider_attest_id,:provider_work_history_id] do |t|
      t.integer        :provider_work_history_id
      t.references     :provider_attest
      t.string         :employer_name
      t.datetime       :start_date
      t.datetime       :end_date
      t.string         :address
      t.string         :address2
      t.string         :city
      t.string         :state
      t.string         :province
      t.string         :postal_code
      t.string         :contact_last_name
      t.string         :contact_first_name
      t.string         :phone_number
      t.text           :exit_explanation
      t.string         :fax_number
      t.string         :title
      t.text           :affiliation_description
      t.text           :operating_status_description
      t.string         :phone_extension
      t.string         :department
      t.string         :email_address
      t.text           :status_description
      t.string         :prof_liability_carrier
      t.boolean        :current_employer_flag
      t.text           :work_history_type_work_history_type_description
      t.string         :country_country_name

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_work_histories
  end
end
