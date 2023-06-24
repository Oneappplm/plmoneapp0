class Import::HvhsService < ApplicationService
	attr_reader :file

	def initialize(file = nil)
		@file = file
	end

	def call
		return	unless file.present?

		data = Roo::Spreadsheet.open(file, extension: :xlsx)

		if data.sheets.size != 0
			data.default_sheet	= data.sheets.first
			data_fields = [
				'npi', 'first_name', 'middle_name', 'last_name', 'degree_titles',
				'office_address_line1', 'office_address_line2', 'office_city', 'office_state',
				'office_zip_code', 'phone_number', 'practice_email_address', 'office_mgr_email',
				'office_mgr_fax', 'office_mgr_first_name',	'office_mgr_last_name', 'office_mgr_phone',
				'special_type', 'taxonomy_code', 'license_number', 'license_state'
			]


			data.each_with_index do |sheet, index|
				if index >	0
					next if sheet.compact.size == 0

				 hvhs_data = HvhsDatum.new
      data_fields.each_with_index do |field, field_index|
        hvhs_data.send("#{field}=", sheet[field_index])
      end
      hvhs_data.save

				end
			end
		end
	end
end
