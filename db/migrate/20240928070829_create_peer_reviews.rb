class CreatePeerReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :peer_reviews do |t|
      t.references :provider, null: false, foreign_key: true
      t.datetime :committee_date
      t.column :review_status, :integer, default: 0 
      t.string :feedback

      t.timestamps
    end
  end
end
