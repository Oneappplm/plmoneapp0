class Import::ProviderTypesService < ApplicationService
	attr_reader :file, :version

	def initialize(file = nil, version = 1)
		@file = file
		@version = version
	end

	def call
		return unless file.present?

		data = Roo::Spreadsheet.open(file, extension: :xlsx)

		if data.sheets.size != 0
			data.default_sheet = data.sheets.first
			if	version == 1
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
			elsif version == 2
				ProviderType.destroy_all
				data.each_with_index do |sheet, index|
					if index > 0
						next if sheet.compact.size == 0

						ProviderType.find_or_create_by(fch: sheet[0])
					end
				end
			elsif version == 3
					ProviderType.destroy_all
				data.each_with_index do |sheet, index|
					if index > 0
						next if sheet.compact.size == 0

						fch = "#{sheet[1]} - #{sheet[0]}"

						ProviderType.find_or_create_by(fch: fch)
					end
				end
			end

		end
	end
end
