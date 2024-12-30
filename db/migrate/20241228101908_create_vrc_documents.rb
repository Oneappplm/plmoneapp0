class CreateVrcDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :vrc_documents do |t|
      t.string :name
      t.date :committee_date
      t.string :file_upload

      t.timestamps
    end
  end
end
