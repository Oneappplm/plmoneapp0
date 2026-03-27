class AddMessageFieldToPdfQueueItems < ActiveRecord::Migration[7.0]
  def change
    add_column :pdf_queue_items, :message, :text
  end
end
