class AddPracticeInformationRefToPracticeLocations < ActiveRecord::Migration[7.0]
  def change
    add_reference :practice_locations, :practice_information, foreign_key: true
  end
end
