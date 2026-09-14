class CreatePdfGenerationQueues < ActiveRecord::Migration[7.0]
  def change
    create_table :pdf_generation_queues do |t|
      t.references :provider_personal_information, null: false, foreign_key: true
      t.string :queue_number
      t.string :status, default: "queued"
      t.datetime :queued_date
      t.datetime :generated_date
      t.text :message
      t.text :selected_links, array: true, default: []
      t.string :pdf_path
      t.timestamps
    end
  end
end
