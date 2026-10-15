class CreateDownloadHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :download_histories do |t|
      t.string :file_name
      t.datetime :downloaded_at
      t.integer :user_id

      t.timestamps
    end
  end
end
