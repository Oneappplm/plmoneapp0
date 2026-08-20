# app/jobs/dmf_import_job.rb
# frozen_string_literal: true

class DmfImportJob < ApplicationJob
  queue_as :long_running

  def perform(dmf_file_version_id)
    version =
      DmfFileVersion.find(dmf_file_version_id)

    Dmf::ImportService.new(version).call
  end
end