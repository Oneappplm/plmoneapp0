# frozen_string_literal: true

class Import::ClientService < ApplicationService
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

				Client.find_or_create_by(
					first_name: sheet[0],
					last_name: sheet[1],
					middle_name: sheet[2],
					title: sheet[3],
					prefix:	sheet[4],
					suffix: sheet[5],
					gender: sheet[6],
					birth_date: sheet[7],
					ssn: sheet[8],
					prac_type: sheet[9],
					specialty_name: sheet[10],
					address1: sheet[11],
					address2: sheet[12],
					city: sheet[13],
					state_or_province:	sheet[14],
					country: sheet[15],
					postal_code: sheet[16],
					primary_phone: sheet[17],
					primary_email: sheet[18],
					client_specified_id: sheet[19],
					medv_id: sheet[20],
					practitioner_guid: sheet[21],
					client_guid: sheet[22],
					file_path: sheet[23],
					signature_date: sheet[24],
					file_status: sheet[25],
					app_receive_date: sheet[26],
					app_receive_complete_date: sheet[27],
					app_complete_date:	sheet[28],
					approval_date:	sheet[29],
					cred_or_recred: sheet[30],
					org_type: sheet[31],
					caqhid: sheet[32],
					import_exid: sheet[33],
					client_id: sheet[34],
					external_id: sheet[35]
				)
			end
		end
	end
end


