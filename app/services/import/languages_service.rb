class Import::LanguagesService < ApplicationService
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

				Language.find_or_create_by(
					name: sheet[0],
				)
			end
		end
	end
end
