class CreateClientProviderEnrollments < ActiveRecord::Migration[7.0]
  def change
    create_table :client_provider_enrollments do |t|
      t.references :enrollable, polymorphic: true, null: false
      t.timestamps
    end
  end
end
