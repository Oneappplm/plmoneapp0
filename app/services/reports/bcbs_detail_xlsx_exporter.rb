require "axlsx"

module Reports
  class BcbsDetailXlsxExporter
    HEADERS = [
      "client_name",
      "Batch_Description",
      "Batch_Date",
      "BCBS_Party_ID",
      "BCBSFL_ID",
      "CAQHID",
      "ClientAlternateID",
      "NPI",
      "First_Name",
      "Middle_Name",
      "Last_Name",
      "Practitioner_Type",
      "Social_Security_Number",
      "Date_of_Birth",
      "Cred_Recred_Status",
      "Committee_Date",
      "Internal_Committee_Date",
      "App_Received_Date",
      "App_Received_Complete_Date",
      "Submitted_Date",
      "Complete_Profile_Return_Date",
      "Incomplete_Profile_Return_Date",
      "Current_PSV",
      "SignatureDate",
      "LiaExpDate",
      "LicExpDate",
      "DEAexpDate",
      "In_Audit",
      "In_Collection",
      "In_Completion",
      "Returned",
      "ProviderStatus",
      "PSV_Age",
      "PSVTAT",
      "Returned_within_Parameters",
      "App_Age",
      "AppTAT",
      "NumberOfCollectionAttempts",
      "AppTrackerID",
      "CollectionItems",
      "FirstCollectionAttempt",
      "AppTracker_Comment",
      "AppTracker_CommentDate",
      "AppTracker_contactMethod",
      "AppTracker_contactStatus",
      "CredentialContactPhone",
      "CredentialContactFax",
      "Profile_Generation_Date",
      "Region",
      "PIMSID",
      "Practicestate",
      "PrimarySpecialty",
      "LatestEdu",
      "NPDBVerifiedDate",
      "NPDBAdverseAction",
      "VRCReviewLevel",
      "VRCcommiteeDate",
      "VRCPSVDate",
      "VRCStatus",
      "QAReason",
      "VRCDateReopened",
      "Apptracking_comments",
      "OutputfileDate",
      "ReviewDetail"
    ].freeze

    VRC_HEADERS = [
      "pracID",
      "providerID",
      "clientName",
      "CommitteeDate",
      "reviewaction",
      "cycleguid",
      "revewDate"
    ].freeze

    attr_reader :client_name

    def initialize(client_name:)
      @client_name = client_name

      @rows =
        Reports::BcbsDetailReportDataBuilder
          .new(client_name: client_name)
          .call
    end

    def call
      package = Axlsx::Package.new

      add_main_sheet(package)
      add_vrc_sheet(package)
      add_empty_sheet(package)

      package
    end

    private

    def add_main_sheet(package)
      package.workbook.add_worksheet(
        name: "Sheet1"
      ) do |sheet|

        # Exact reference headers.
        # No additional design or formatting.
        sheet.add_row HEADERS

        @rows.each do |row|
          sheet.add_row row_values(row)
        end
      end
    end

    def add_vrc_sheet(package)
      package.workbook.add_worksheet(
        name: "VRCDetails"
      ) do |sheet|

        sheet.add_row VRC_HEADERS

        vrc_rows.each do |row|
          sheet.add_row row
        end
      end
    end

    def add_empty_sheet(package)
      package.workbook.add_worksheet(
        name: "Sheet3"
      )
    end

    def row_values(row)
      [
        row[:client_name],
        row[:batch_description],
        row[:batch_date],
        row[:bcbs_party_id],
        row[:bcbsfl_id],
        row[:caqh_id],
        row[:client_alternate_id],
        row[:npi],
        row[:first_name],
        row[:middle_name],
        row[:last_name],
        row[:practitioner_type],
        row[:social_security_number],
        row[:date_of_birth],
        row[:cred_recred_status],
        row[:committee_date],
        row[:internal_committee_date],
        row[:app_received_date],
        row[:app_received_complete_date],
        row[:submitted_date],
        row[:complete_profile_return_date],
        row[:incomplete_profile_return_date],
        row[:current_psv],
        row[:signature_date],
        row[:lia_exp_date],
        row[:lic_exp_date],
        row[:dea_exp_date],
        row[:in_audit],
        row[:in_collection],
        row[:in_completion],
        row[:returned],
        row[:provider_status],
        row[:psv_age],
        row[:psv_tat],
        row[:returned_within_parameters],
        row[:app_age],
        row[:app_tat],
        row[:number_of_collection_attempts],
        row[:app_tracker_id],
        row[:collection_items],
        row[:first_collection_attempt],
        row[:app_tracker_comment],
        row[:app_tracker_comment_date],
        row[:app_tracker_contact_method],
        row[:app_tracker_contact_status],
        row[:credential_contact_phone],
        row[:credential_contact_fax],
        row[:profile_generation_date],
        row[:region],
        row[:pims_id],
        row[:practice_state],
        row[:primary_specialty],
        row[:latest_edu],
        row[:npdb_verified_date],
        row[:npdb_adverse_action],
        row[:vrc_review_level],
        row[:vrc_committee_date],
        row[:vrc_psv_date],
        row[:vrc_status],
        row[:qa_reason],
        row[:vrc_date_reopened],
        row[:apptracking_comments],
        row[:outputfile_date],
        row[:review_detail]
      ]
    end

    def vrc_rows
      return [] unless defined?(VirtualReviewCommittee)

      provider_ids =
        ProviderPersonalInformation
          .where(
            legacy_client_name: client_name
          )
          .pluck(:id)

      VirtualReviewCommittee
        .where(provider_id: provider_ids)
        .order(:provider_id, :created_at)
        .map do |vrc|

        [
          vrc.provider_id,
          vrc.medv_id,
          client_name,
          vrc.committee_date,
          vrc.status,
          vrc.provider_cycle_id,
          vrc.review_date
        ]
      end
    end
  end
end
