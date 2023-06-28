class Import::QualifactsService < ApplicationService
	attr_reader	:file

	def initialize(file = nil)
		@file = file
	end

	def call
		return unless file.present?

		data = Roo::Spreadsheet.open(file, extension: :xlsx)

		if data.sheets.size != 0
			data.default_sheet	= data.sheets.first

			data.each_with_index do |sheet, index|
				if	index > 0
					next	if sheet.compact.size == 0

					provider	= Provider.new(
						practice_location_name:	sheet[0],
						provider_effective_date:	sheet[1],
						first_name:	sheet[2],
						middle_name:	sheet[3],
						last_name:	sheet[4],
						practitioner_type:	sheet[5],
						ssn:	sheet[6],
						birth_date:	sheet[7],
						npi:	sheet[8],
						caqh_id:	sheet[9],
						caqh_pdf:	sheet[10],
						caqh_attestation_date:	sheet[11],
						caqh_login:	sheet[12],
						caqh_password:	sheet[13],
						reattestation_date:	sheet[14],
						security_question_answer:	sheet[15],
						taxonomy:	sheet[16],
						specialty:	sheet[17],
						board_certified:	sheet[18],
						birth_city_state: sheet[19],
						medical_school:	sheet[20],
						medical_license:	sheet[21],
						state_license:	sheet[22],
						state_license_effectice_date: sheet[23],
						state_license_expiration_date: sheet[24],
						pa_license_number:	sheet[25],
						pa_license_effective_date:	sheet[26],
						pa_license_expiration_date:	sheet[27],
						nccpa_number:	sheet[28],
						nccpa_expiration_date: sheet[29],
						np_license_number:	sheet[30],
						np_license_effective_date:	sheet[31],
						np_license_expiration_date:	sheet[32],
						rn_license_number:	sheet[33],
						rn_license_effective_date:	sheet[34],
						rn_license_expiration_date:	sheet[35],
						dea_number:	sheet[36],
						dea_license_effective_date:	sheet[37],
						dea_license_expiration_date:	sheet[38],
						ins_policy: sheet[39],
						ins_policy_effective_date: sheet[40],
						ins_policy_expiration_date: sheet[41],
						oig:	sheet[42],
						sam:	sheet[43],
					)

					provider.save(validate: false)
				end
			end

		end
	end
end