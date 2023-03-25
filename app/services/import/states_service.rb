class Import::StatesService < ApplicationService
	attr_reader :file

	def initialize(file = nil)
		@file = file
	end

	def call
		return unless file.present?

		data = Roo::Spreadsheet.open(file, extension: :xlsx)

		if data.sheets.size != 0
			data.default_sheet = data.sheets.first

			data.each do |sheet|

				next if sheet.compact.size == 0

				State.find_or_create_by(
					name: sheet[0],
					alpha_code: sheet[1]
				)
			end
		end
	end
end
