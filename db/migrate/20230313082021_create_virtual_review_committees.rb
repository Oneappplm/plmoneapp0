class CreateVirtualReviewCommittees < ActiveRecord::Migration[7.0]
  def change
    create_table :virtual_review_committees do |t|
      t.string :provider_name
      t.string :provider_type
      t.string :state
      t.string :cred_cycle
      t.datetime :psv_completed_date
      t.string :review_level
      t.datetime :recred_due_date
      t.datetime :review_date
      t.datetime :committee_date
      t.datetime :vote_date
      t.string :status
      t.string :progress_status, default: 'completed'

      t.timestamps
    end
  end
end
