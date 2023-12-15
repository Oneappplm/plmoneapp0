class Import::PayorNamesService < ApplicationService
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
			data.each_with_index do |sheet, index|
				if index > 0
					next if sheet.compact.size == 0

					PayorName.find_or_create_by(
						title: sheet[0],
					)
				end
			end
		end
	end
end
