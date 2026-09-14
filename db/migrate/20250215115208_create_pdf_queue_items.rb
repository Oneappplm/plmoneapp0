class CreatePdfQueueItems < ActiveRecord::Migration[7.0]
  def change
    create_table :pdf_queue_items do |t|
      t.references :pdf_generation_queue, null: false, foreign_key: true
      t.string :file_name
      t.string :file_path
      t.string :status, default: "queued" # queued, processing, completed, error

      t.timestamps
    end
  end
end
