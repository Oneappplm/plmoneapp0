class CreateProviderEmployments < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_employments do |t|
        t.references :provider_attest, null: false, foreign_key: true
        t.string :employer_name
        t.string :title
        t.string :contact_first_name
        t.string :contact_middle_name
        t.string :contact_last_name
        t.string :contact_suffix
        t.string :practitioner_type
        t.string :address
        t.string :mail_stop
        t.string :additional_address
        t.string :city
        t.string :county
        t.string :state
        t.string :country
        t.string :zip
        t.string :phone_number
        t.string :fax
        t.string :email
        t.string :work_status
        t.string :population_serviced
        t.string :contact_method
        t.date :from_date
        t.date :to_date
        t.string :position
        t.boolean :show_on_tickler
        t.text :comments
      t.timestamps
    end
  end
end
