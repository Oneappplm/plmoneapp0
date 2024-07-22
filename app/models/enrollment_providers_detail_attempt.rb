class EnrollmentProvidersDetailAttempt < ApplicationRecord
  self.table_name = "epd_attempts"

  attr_accessor :user_full_name
  belongs_to :enrollment_providers_detail
  belongs_to :user

  STATUS = [
            ["First Attempt", "first_attempt"],
            ["Second Attempt", "second_attempt"],
            ["Third Attempt", "third_attempt"],
            ["Additional Attempt", "additional_attempt"],
            ["Confirmed Application Received", "confirmed_application_received"],
            ["No Answer", "no_answer"],
            ["For Follow Up", "for_follow_up"],
            ["Application Submitted", "application_submitted"],
            ["Application Not Submitted", "application_not_submitted"],
            ["Pending - Missing Information", "pending_missing_information"],
            ["Pending - Login Details", "pending_login_details"]
          ]
end
