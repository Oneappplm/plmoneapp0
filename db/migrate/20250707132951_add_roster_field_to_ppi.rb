class AddRosterFieldToPpi < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :roster, :boolean
    add_column :provider_sources, :roster, :boolean
    add_column :provider_personal_informations, :psv_completed_date, :datetime
  end
end
