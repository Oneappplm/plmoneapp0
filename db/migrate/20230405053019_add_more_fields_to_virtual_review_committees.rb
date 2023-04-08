class AddMoreFieldsToVirtualReviewCommittees < ActiveRecord::Migration[7.0]
  def change
    add_column :virtual_review_committees, :client_id, :integer
    add_column :virtual_review_committees, :provider_id, :integer
    add_column :virtual_review_committees, :provider_cycle_id, :string
    add_column :virtual_review_committees, :medv_id, :integer
    add_column :virtual_review_committees, :first_name, :string
    add_column :virtual_review_committees, :last_name, :string
    add_column :virtual_review_committees, :cred_or_recred, :string
    add_column :virtual_review_committees, :app_complete_data, :string
    add_column :virtual_review_committees, :voted_by, :string
    add_column :virtual_review_committees, :specialty, :string
    add_column :virtual_review_committees, :region, :string
    add_column :virtual_review_committees, :committee_approval_date, :string
    add_column :virtual_review_committees, :assignment_indicator, :string
    add_column :virtual_review_committees, :orig_synch_date, :string
    add_column :virtual_review_committees, :review_details, :string
  end
end