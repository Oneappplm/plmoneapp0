# app/models/dmf_record.rb
# frozen_string_literal: true

class DmfRecord < ApplicationRecord
  belongs_to :dmf_file_version

  validates :ssn,
            presence: true,
            format: { with: /\A\d{9}\z/ }

  scope :for_ssn, ->(ssn) {
    where(ssn: ssn.to_s.gsub(/\D/, ""))
  }
end