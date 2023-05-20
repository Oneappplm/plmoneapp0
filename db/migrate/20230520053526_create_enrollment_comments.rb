class CreateEnrollmentComments < ActiveRecord::Migration[7.0]
  def change
    create_table :enrollment_comments do |t|
      t.references :enrollment_provider
      t.references :enroll_group
      t.references :provider
      t.references :user
      t.string :body

      t.timestamps
    end
  end
end
