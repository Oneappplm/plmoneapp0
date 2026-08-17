# frozen_string_literal: true

class ProviderSsnVerification < ApplicationRecord
  STATUSES = %w[
    matched
    not_matched
    review_required
    error
  ].freeze

  belongs_to :provider_personal_information

  belongs_to :dmf_file_version, optional: true

  belongs_to :provider_attest,
             optional: true

  belongs_to :verified_by,
             class_name: "User",
             optional: true

  mount_uploader :report_pdf, SsaVerificationPdfUploader

  # has_one_attached :report_pdf

  validates :status,
            presence: true,
            inclusion: { in: STATUSES }

  validates :ssn_last_four,
            length: { is: 4 },
            allow_blank: true

  scope :latest_first, -> { order(verified_at: :desc, created_at: :desc) }

  def matched?
    status == "matched"
  end

  def not_matched?
    status == "not_matched"
  end

  def review_required?
    status == "review_required"
  end

  def error?
    status == "error"
  end

  def display_status
    status.to_s.humanize
  end
end