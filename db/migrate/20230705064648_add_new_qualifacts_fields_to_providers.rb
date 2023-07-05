class AddNewQualifactsFieldsToProviders < ActiveRecord::Migration[7.0]
  def up
    add_column :providers, :status, :string
    add_column :providers, :caqh_current_reattestation_date, :datetime
    add_column :providers, :caqh_reattest_completed_by, :string
    add_column :providers, :caqh_question, :string
    add_column :providers, :caqh_answer, :string
    add_column :providers, :caqh_notes, :string
    add_column :providers, :licensed_registered_state_id, :integer
  end

  def down
    remove_column :providers, :status, :string
    remove_column :providers, :caqh_current_reattestation_date, :datetime
    remove_column :providers, :caqh_reattest_completed_by, :string
    remove_column :providers, :caqh_question, :string
    remove_column :providers, :caqh_answer, :string
    remove_column :providers, :caqh_notes, :string
    remove_column :providers, :licensed_registered_state_id, :integer
  end
end

