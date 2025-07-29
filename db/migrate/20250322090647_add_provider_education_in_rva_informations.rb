class AddProviderEducationInRvaInformations < ActiveRecord::Migration[7.0]
  def change
    add_reference :rva_informations, :practice_information_education, foreign_key: true
    add_reference :rva_informations, :provider_education, foreign_key: true
    add_reference :rva_informations, :provider_specialty, foreign_key: true
    add_reference :rva_informations, :provider_licensure, foreign_key: true
    add_reference :rva_informations, :provider_insurance_coverage, foreign_key: true
    add_reference :rva_informations, :provider_employment, foreign_key: true
  end
end
