class AddTemporaryPdfQuqueItems < ActiveRecord::Migration[7.0]
  def change
    add_column :pdf_queue_items, :temporary, :boolean, default: false
  end
end
