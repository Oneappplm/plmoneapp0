class AddFacilityApplicationToUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :facility_application, foreign_key: true, index: true
  end
end
