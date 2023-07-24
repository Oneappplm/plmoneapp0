class AddMoreFieldToEnrollGroupsDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :enroll_groups_details, :payer_state, :string
  end
end
