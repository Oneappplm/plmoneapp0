class CreatePractitionerProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :practitioner_profiles do |t|
      t.string :name
      t.timestamps
    end
  end
end
