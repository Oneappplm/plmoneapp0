class AddFieldToPdfGerenationQueue < ActiveRecord::Migration[7.0]
  def change
    add_column :pdf_generation_queues, :deleted, :boolean
  end
end
