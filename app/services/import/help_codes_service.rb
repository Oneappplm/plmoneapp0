class Import::HelpCodesService < ApplicationService
  attr_reader :file
 
  def initialize(file = nil)
   @file = file 
  end
 
  def call
   return unless file.present?
   
   data = Roo::Spreadsheet.open(file, extension: :csv)
   if data.sheets.size != 0
     data.default_sheet = data.sheets.first
 
     data.each_with_index do |sheet, index|
 
       next if sheet.compact.size == 0 || index < 1
 
       HelpCode.find_or_create_by(
         category: sheet.first,
         code: sheet.second
       )
 
       puts "Done creating #{sheet.first} with code #{sheet.second}."
     end
   end
 
  end
 end
 