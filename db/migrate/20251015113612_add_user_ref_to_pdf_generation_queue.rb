class AddUserRefToPdfGenerationQueue < ActiveRecord::Migration[7.0]
  def change
    add_reference :pdf_generation_queues, :user, foreign_key: true
    add_column :pdf_generation_queues, :merge_enqueued, :boolean, default: false, null: false
  end
end
