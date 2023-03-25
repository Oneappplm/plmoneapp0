class Import::ProviderTypesService < ApplicationService
	attr_reader :file

	def initialize(file = nil)
		@file = file
	end

	def call
		return unless file.present?

		data = Roo::Spreadsheet.open(file, extension: :xlsx)

		if data.sheets.size != 0
			data.default_sheet = data.sheets.first

			data.each_with_index do |sheet, index|
				if index > 0
					next if sheet.compact.size == 0

					ProviderType.find_or_create_by(
						fch: sheet[0],
						bcbs: sheet[1],
						perform_rx: sheet[2],
						dwihn: sheet[3],
						met_life: sheet[4],
						pharmpix: sheet[5],
						broward_health: sheet[6],
						ochn: sheet[7],
						primary_partner_care: sheet[8],
						sdsu_student_health_services: sheet[9],
						ucamc: sheet[10],
						macomb_country: sheet[11],
						nkcph: sheet[12],
					)
			 end
			end
		end
	end
end
