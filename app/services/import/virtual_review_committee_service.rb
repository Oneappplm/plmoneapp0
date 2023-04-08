# frozen_string_literal: true

class Import::VirtualReviewCommitteeService < ApplicationService
		attr_reader :file

		def initialize(file = nil)
				@file = file
		end

		def call
				return unless file.present?

				data = Roo::Spreadsheet.open(file, extension: :csv)

				if data.sheets.size != 0
						data.default_sheet = data.sheets.first

						data.each do |sheet|

								next if sheet.compact.size == 0

								VirtualReviewCommittee.find_or_create_by(
										client_id: sheet[0],
										provider_name: sheet[1],
										first_name: sheet[2],
										last_name: sheet[3],
										state: sheet[4],
										provider_id: sheet[5],
										provider_type: sheet[6],
										cred_or_recred:	sheet[7],
										review_level: sheet[8],
										app_complete_data:	sheet[9],
										recred_due_date: sheet[10],
										status: sheet[11],
										vote_date: sheet[12],
										voted_by: sheet[13],
										review_date: sheet[14],
										specialty: sheet[15],
										region: sheet[16],
										committee_approval_date: sheet[17],
										provider_cycle_id: sheet[18],
										medv_id: sheet[19],
										assignment_indicator: sheet[20],
										orig_synch_date: sheet[21],
										review_details: sheet[22],
								)
						end
				end
		end
end
