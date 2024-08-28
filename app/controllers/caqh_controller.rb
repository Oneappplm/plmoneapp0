class CaqhController < ApplicationController
  protect_from_forgery with: :null_session

  def show
  end

  def upload
    ActiveRecord::Base.transaction do
      update_or_create_provider_personal_informations
      update_or_create_practice_information
      update_or_create_practice_accessibility
      update_or_create_practice_associate
    end
    head :ok
  end

  private
  def update_or_create_provider_personal_informations
    file = File.read(params[:ProviderPersonalInformation])
    csv = CSV.parse(file, :headers => true, col_sep: "|")
    csv.each do |row|
      provider_attest = ProviderAttest.find_or_create_by(provider_attest_id: row["ProviderAttestID"])

      provider_personal_information = ProviderPersonalInformation.find_or_initialize_by({
        "provider_id": row["ProviderID"],
        "provider_attest_id": provider_attest.id
      })
      provider_personal_information.assign_attributes_from_csv_row(row)

      provider_personal_information.save!
    end
  end

  def update_or_create_practice_information
    file = File.read(params[:PracticeInformation])
    csv = CSV.parse(file, :headers => true, col_sep: "|")
    csv.each do |row|
      practice_information = PracticeInformation.find_or_initialize_by({
        "provider_practice_id": row["ProviderPracticeID"],
        "provider_attest_id":  row["ProviderAttestID"]
      })
      practice_information.assign_attributes_from_csv_row(row)

      practice_information.save!
    end
  end

  def update_or_create_practice_accessibility
    file = File.read(params[:PracticeAccessibility])
    csv = CSV.parse(file, :headers => true, col_sep: "|")
    csv.each do |row|
      practice_accessibility = PracticeAccessibility.find_or_initialize_by({
        "provider_practice_accessibility_id": row["ProviderPracticeAccessibilityID"],
        "provider_attest_id":  row["ProviderAttestID"]
      })
      practice_accessibility.assign_attributes_from_csv_row(row)

      practice_accessibility.save!
    end
  end

  def update_or_create_practice_associate
    file = File.read(params[:PracticeAssociate])
    csv = CSV.parse(file, :headers => true, col_sep: "|")
    csv.each do |row|
      practice_associate = PracticeAssociate.find_or_initialize_by({
        "provider_practice_associate_id": row["ProviderPracticeAccessibilityID"],
        "provider_attest_id":  row["ProviderAttestID"]
      })
      practice_associate.assign_attributes_from_csv_row(row)

      practice_associate.save!
    end
  end
end
