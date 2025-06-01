module Api
  module V1
    class Base < Grape::API
      version 'v1', using: :path
      format :json

      helpers Api::Helpers::Authentication

      # Apply authentication to all endpoints in this version
      before do
        authenticate!
      end

      rescue_from ActiveRecord::RecordNotFound do
        error!('Record not found', 404)
      end

      rescue_from Grape::Exceptions::ValidationErrors do |e|
        error!({ errors: e.full_messages }, 400)
      end

      rescue_from StandardError do |e|
        error!({ errors: e }, 400)
      end

      # Mount specific resources for V1
      mount Api::V1::Users
      mount Api::V1::Roles
      mount Api::V1::RoleBasedAccesses
      mount Api::V1::Providers
      mount Api::V1::DirectorProviders
      mount Api::V1::EnrollGroups
      mount Api::V1::UsersEnrollmentGroups
      mount Api::V1::Clients
      mount Api::V1::EnrollGroupsDetails
      mount Api::V1::EnrollmentProviders
      mount Api::V1::Settings
      mount Api::V1::ProviderLicenses
      mount Api::V1::ProviderBoardCertifications
      mount Api::V1::ProviderTaxonomies
      mount Api::V1::ProviderDeaLicenses
      mount Api::V1::VirtualReviewCommittees
      mount Api::V1::GroupDcos
      mount Api::V1::ClientOrganizations
      mount Api::V1::PracticeLocations
      mount Api::V1::ProviderNotes
      mount Api::V1::EnrollmentComments
      mount Api::V1::GroupDcoNotes
      mount Api::V1::ProviderSources
      mount Api::V1::ProviderSourceCmes
      mount Api::V1::ProviderSourceData
      mount Api::V1::ProviderSourcesCds
      mount Api::V1::ProviderSourcesDeas
      mount Api::V1::PeerReviews
      mount Api::V1::PeerRecommendations
      mount Api::V1::WorkHistoryProviders
      mount Api::V1::GroupContacts
      mount Api::V1::GroupDcoSchedules
      mount Api::V1::AddSchedules
      mount Api::V1::DisclosureCategories
      mount Api::V1::DisclosureQuestions
      mount Api::V1::EnrollmentGroupsDetailsQuestions
      mount Api::V1::EnrollmentGroupSvcLocations
      mount Api::V1::EnrollmentGroupsContactDetails
      mount Api::V1::EnrollmentGroupsDetails
      mount Api::V1::EnrollmentPayers
      mount Api::V1::EnrollmentProvidersDetails
      mount Api::V1::EpdQuestions
      mount Api::V1::GroupDcoOldLocationAddresses
      mount Api::V1::GroupDcoProviderOutreachInformations
      mount Api::V1::GroupEngageProviders
      mount Api::V1::HvhsData
      mount Api::V1::ProviderCdsLicenses
      mount Api::V1::ProviderCnpLicenses
      mount Api::V1::ProviderInsPolicies
      mount Api::V1::ProviderMccs
      mount Api::V1::ProviderMedicaids
      mount Api::V1::ProviderMedicares
      mount Api::V1::ProviderMnLicenses
      mount Api::V1::ProviderMnMedicaids
      mount Api::V1::ProviderNpLicenses
      mount Api::V1::ProviderPaLicenses
      mount Api::V1::ProviderRnLicenses
      mount Api::V1::ProviderSourcesRegistrations
      mount Api::V1::ProviderWiMedicaids
      mount Api::V1::ProvidersMissingFieldSubmissions
      mount Api::V1::ProvidersMissingFieldSubmissionsData
      mount Api::V1::ProvidersPayerLogins
      mount Api::V1::ProvidersPayerLoginsQuestions
      mount Api::V1::ProvidersServiceLocations
      mount Api::V1::ProvidersTimeLines
      mount Api::V1::WebscraperAlaskaStates
      mount Api::V1::WebscraperCaliforniaStates
      mount Api::V1::BoardNames
      mount Api::V1::Directories
      mount Api::V1::EducationTypes
      mount Api::V1::GroupRoles
      mount Api::V1::HealthPlans
      mount Api::V1::HelpCodes
      mount Api::V1::Hospitals
      mount Api::V1::Languages
      mount Api::V1::MethodResolutions
      mount Api::V1::PracticeTypes
      mount Api::V1::PractitionerProfiles
      mount Api::V1::PrivilegeStatuses
      mount Api::V1::ProviderTypes
      mount Api::V1::ServicedPopulations
      mount Api::V1::Services
      mount Api::V1::Specialties
      mount Api::V1::TrainingTypes
      mount Api::V1::VisaTypes
      mount Api::V1::ProviderSourceDocuments
      mount Api::V1::EgdLogs
      mount Api::V1::EpdLogs
      mount Api::V1::States
      mount Api::V1::ClientProviderEnrollments
      mount Api::V1::ProviderDeletedDocumentLogs
    end
  end
end
