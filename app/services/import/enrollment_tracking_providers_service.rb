class Import::EnrollmentTrackingProvidersService < ApplicationService
	attr_reader :file

	def initialize(file = nil)
		@file = file
	end

	def call
		return unless file.present?

		data = Roo::Spreadsheet.open(file, extension: :xlsx)

		if	data.sheets.size != 0

			# Provider.destroy_all

			data.default_sheet = data.sheets.first

			data.each_with_index do |sheet, index|
				if index > 0
					next if sheet.compact.size == 0 || Provider.exists?(first_name:	sheet[3], middle_name: sheet[4], last_name: sheet[5])

					provider = Provider.new(
						roster_result: sheet[0],
						terminated: sheet[1],
						dco_name: sheet[2],
						first_name:	sheet[3],
						middle_name: sheet[4],
						last_name: sheet[5],
						practitioner_type: sheet[6],
						ssn:	sheet[7],
						birth_date: sheet[8],
						npi:	sheet[9],
						caqh_id: sheet[10],
						caqh_pdf:	sheet[11],
						caqh_attestation_date: sheet[12],
						taxonomy:	sheet[13],
						specialty:	sheet[14],
						license_number:	sheet[15],
						license_effective_date:	sheet[16],
						license_expiration_date:	sheet[17],
						pa_license_expiration_date:	sheet[18],
						nccpa_number:	sheet[19],
						np_license_number:	sheet[20],
						np_license_effective_date:	sheet[21],
						np_license_expiration_date:	sheet[22],
						rn_license_number:	sheet[23],
						rn_license_effective_date:	sheet[24],
						rn_license_expiration_date:	sheet[25],
						dea_number:	sheet[26],
						dea_license_effective_date:	sheet[27],
						dea_license_expiration_date:	sheet[28],
						liability_issue_date:	sheet[29],
						liability_expiration_date:	sheet[30],
						policy_number:	sheet[31],
						oig:	sheet[32],
						sam:	sheet[33],
						medicare:	sheet[34],
						medicare_revalidation_date:	sheet[35],
						medicaid:	sheet[36],
						medicaid_revalidation_date:	sheet[37],
						molina:	sheet[38],
						mclaren:	sheet[39],
						meridian:	sheet[40],
						aetna:	sheet[41],
						priority_health:	sheet[42],
						amerihealth:	sheet[43],
					)

					provider.save(validate: false)

				end
			end
		end

	end
end
