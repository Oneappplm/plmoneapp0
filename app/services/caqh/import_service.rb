# frozen_string_literal: true

class Caqh::ImportService < ApplicationService
  attr_reader :params

  UNFILTERED_MODEL_CLASSES = ["PracticeInformation", "ProviderPersonalInformation", "ProviderAssociate", "PracticeAssociate", "ProviderEducation", "PracticeOtherQuestions", "ProviderHospitalPrivilege", "ProviderMalpracticeHistory", "ProviderMedicalCondition", "ProviderDegree", "ProviderMedicaid", "PracticeLimitation", "ProviderIdentificationNumbers", "PracticeSpecialty", "PracticeLanguage", "PracticeAssociateSpecialty", "PracticeHours", "ProviderOtherName", "PracticeCertification", "ProviderTimeGap", "ProviderMedicalAssociation", "ProviderOtherBusinessInterest", "PracticeAssociateOtherQuestions", "PracticeService", "ProviderMilitary", "PracticePhoneCoverage", "ProviderMedicalLicense", "ProviderInsuranceCoverage", "ProviderEducationAssociate", "ProviderAdverseAction", "PracticeAccessibility", "PracticeTaxID", "ProviderMalpracticeCaseStatus", "ProviderRaceEthnicity", "ProviderLanguage", "PracticePatientType", "ProviderHospitalAssociate", "ProviderNon-PracticeAddress", "PracticeBusinessArrangement", "ProviderCDS", "ProviderMedicalConditionProvider", "PracticeOtherTaxID", "ProviderOtherQuestions", "ProviderMedicare", "PracticeOtherAddress", "ProviderWorkHistory", "ProviderReference", "ProviderLiabilityAction", "ProviderDEA", "ProviderSubstanceAbuse", "ProviderSpecialty", "ProviderCriminalAction", "ProviderDisclosure", "ProviderOtherInterest", "ProviderCertification"]

  def initialize(params = {})
   @params = params
  end

  def call
    UNFILTERED_MODEL_CLASSES.each do |model|
      model_param = params.dig(model.to_sym)
      model_class = filtered_model_class(model)
      next unless model_param && Object.const_defined?(model_class)

      file = File.read(model_param)
      csv  = CSV.parse(file, :headers => true, col_sep: "|")

      csv.each do |row|
        Caqh::BaseRepository.call(row, model_class, keys_replacement(model_class))
      end
    end
  end

  private

  def keys_replacement model
    case model
     when "ProviderPersonalInformation"
      {"correspondence_address_type_correspondence_address_type_description"=>"correspondence_address_type_correspondence_address_type_descrip"}
     else
      {}
    end
  end

  def filtered_model_class model
    model.singularize.gsub("-","").gsub(/([A-Z]+)$/) { |match| match.capitalize }
  end
end
