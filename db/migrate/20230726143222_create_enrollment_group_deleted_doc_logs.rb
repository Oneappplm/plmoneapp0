class CreateEnrollmentGroupDeletedDocLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :enrollment_group_deleted_doc_logs do |t|
      t.references :enrollment_group, null: false, foreign_key: true
      t.string :document_key
      t.string :title
      t.string :note
      t.string :deleted_by
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
