class AddVerificationStatusToPracticeInformationEducations < ActiveRecord::Migration[7.0]
  def change
    add_column :practice_information_educations, :verification_status, :string
  end
end
