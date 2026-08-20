# app/models/dmf_file_version.rb
# frozen_string_literal: true

class DmfFileVersion < ApplicationRecord
  STATUSES = %w[
    pending
    importing
    validating
    completed
    failed
  ].freeze

  has_many :dmf_records,
           dependent: :delete_all

  validates :source_filename,
            :artifact_key,
            :sha256,
            presence: true

  validates :status,
            inclusion: { in: STATUSES }

  scope :latest_first,
        -> { order(publication_date: :desc, created_at: :desc) }

  scope :active_version,
        -> { where(active: true) }

  def self.current
    active_version.order(created_at: :desc).first
  end

  def completed?
    status == "completed"
  end

  def citation
    [
      "SSA Death Master File",
      publication_date&.strftime("%Y-%m-%d"),
      "Version #{id}"
    ].compact.join(" - ")
  end
end