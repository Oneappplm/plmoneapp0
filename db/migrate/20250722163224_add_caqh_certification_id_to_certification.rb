class AddCaqhCertificationIdToCertification < ActiveRecord::Migration[7.0]
  def change
    add_column :certifications, :caqh_provider_certification_id, :integer
  end
end
