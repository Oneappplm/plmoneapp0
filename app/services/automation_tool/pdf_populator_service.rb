class AutomationTool::PdfPopulatorService < ApplicationService
  attr_reader :template_path, :data, :output_path, :template
  
  def initialize(template_path, data, template = "careington", custom_file_name = nil)
    @template_path = template_path
    @data = data
    @template = template
    @output_path = generate_unique_output_path(custom_file_name)
  end

  def call
    doc = HexaPDF::Document.open(template_path)

    if doc.acro_form
      doc.acro_form.each_field do |field|
        case field.field_name
        # Dentist Information
        when 'First Name', 'text_firstname', 'txt_firstname'
          field.field_value = data[:first_name]
        when 'Middle Initial', 'text_middlename', 'txt_middlename'
          field.field_value = data[:middle_initial]
        when 'Last Name', 'text_lastname', 'txt_lastname'
          field.field_value = data[:last_name]
        when 'Date of  birth'
          field.field_value = data[:dob]
        when 'National Provider Identifier Individual NPI'
          field.field_value = data[:npi]
        when 'Social Security Number'
          field.field_value = data[:sss]
        when 'dochub_cb_d65213f80dcc44fc' # General Dentist Checkbox
          field.field_value = data[:specialty] == 'General Dentist'
        when 'State Dental License'
          field.field_value = data[:license_number]
        when 'Graduation Date Month  Year'
          field.field_value = set_date_field(field, :graduation_date, data)

        # Specialist Details
        when 'dochub_cb_ffde27df45375493' # Board certified cb
          field.field_value = data[:board_certified] == 'Yes'
        when 'dochub_cb_6dd2aeadc21cda8f' # Hospital Privileges cb yes
          field.field_value = data[:hospital_privileges] == 'Yes'
        when 'dochub_cb_334f90cb2227234a' # Hospital Privileges cb no
          field.field_value = data[:hospital_privileges] == 'No'
        when 'Deep SedationGeneral anesthesia'
          field.field_value = data[:sedation_privileges] == 'Deep Sedation General Anesthesia'
        when 'ModerateConscious Sedation all types'
          field.field_value = data[:sedation_privileges] == 'Moderate Conscious Sedation All Types'
        when 'Minimal Sedation all types'
          field.field_value = data[:sedation_privileges] == 'Minimal Sedation All Types'
        when 'Pediatric ModeratelyConscious'
          field.field_value = data[:sedation_privileges] == 'Pediatric Moderately Conscious'
        when 'Nitrous Oxide'
          field.field_value = data[:sedation_privileges] == 'Nitrous Oxide'

        # Document Information
        when 'Check Box3' # W9 cb
          field.field_value = data[:w9_included]
        when 'Check Box4' # Dea certificate cb
          field.field_value = data[:dea_certificate]
        when 'Check Box5' # Liability Insurance cb
          field.field_value = coverage_valid_through_end_of_month?(data[:liability_coverage])
        # TODO: Malpractice Checkbox missing in the form.

        # Practice Location 
        when 'Dental School'
          field.field_value = data[:dental_school]
        when 'Dental Office Name'
          field.field_value = data[:office_name]
        when 'Address'
          field.field_value = "#{data[:address]}, #{data[:office_city]}, #{data[:state]}, #{data[:zip]}"
        when 'City_3'
          field.field_value = data[:office_city]
        when 'State_6'
          field.field_value = data[:state]
        when 'ZIP Code'
          field.field_value = data[:zip]
        when 'Tax ID  Required'
          field.field_value = data[:tax_id]
        when 'Tel No'
          field.field_value = data[:phone_number]
        when 'Fax No'
          field.field_value = data[:fax_number]
        when 'Mon'
          field.field_value = time_value(data[:office_hours][:monday], 0)
        when 'ampm'
          field.field_value = time_value(data[:office_hours][:monday], 1)
        when 'Tues'
          field.field_value = time_value(data[:office_hours][:tuesday], 0)
        when 'ampm_2'
          field.field_value = time_value(data[:office_hours][:tuesday], 1)
        when 'Wed'
          field.field_value = time_value(data[:office_hours][:wednesday], 0)
        when 'ampm_3'
          field.field_value = time_value(data[:office_hours][:wednesday], 1)
        when 'Thurs'
          field.field_value = time_value(data[:office_hours][:thursday], 0)
        when 'ampm_4'
          field.field_value = time_value(data[:office_hours][:thursday], 1)
        when 'Fri'
          field.field_value = time_value(data[:office_hours][:friday], 0)
        when 'ampm_5'
          field.field_value = time_value(data[:office_hours][:friday], 1)
        when 'dochub_cb_8208742f40a35fe2'
          field.field_value = data[:ada_compliance] == 'Yes'
        when 'dochub_cb_597f4617e949aee2'
          field.field_value = data[:ada_compliance] == 'No'
        when 'dochub_cb_f78b421f758050cb'
          field.field_value = data[:accepting_new_patients] == 'Yes'
        when 'dochub_cb_fef848a70f8b3396'
          field.field_value = data[:accepting_new_patients] == 'No'

        # Work history
        when 'First Name_2'
          field.field_value = data[:first_name]
        when 'Middle Initial_2'
          field.field_value = data[:middle_initial]
        when 'Last Name_2'
          field.field_value = data[:last_name]
        when 'Practice NameInstitution'
          field.field_value = data[:work_history][0][:practice_name]
        when 'Address_4'
          field.field_value = address_value(data[:work_history][0][:address], 0)
        when 'City_6'
          field.field_value = address_value(data[:work_history][0][:address], 1)
        when 'ZIP'
          field.field_value = address_value(data[:work_history][0][:address], 3)
        when 'From'
          field.field_value = set_date_field(field, [:work_history, 0, :start_date], data)
        when 'To_3'
          field.field_value = set_date_field(field, [:work_history, 0, :end_date], data)
        when 'Practice NameInstitution_2'
          field.field_value = data[:work_history][1][:practice_name]
        when 'Address_5'
          field.field_value = address_value(data[:work_history][1][:address], 0)
        when 'City_7'
          field.field_value = address_value(data[:work_history][1][:address], 1)
        when 'ZIP_2'
          field.field_value = address_value(data[:work_history][1][:address], 3)
        when 'From_2'
          field.field_value = set_date_field(field, [:work_history, 1, :start_date], data)
        when 'To_4'
          field.field_value = set_date_field(field, [:work_history, 1, :end_date], data)
        when 'Practice NameInstitution_3'
          field.field_value = data[:work_history][2][:practice_name]
        when 'Address_6'
          field.field_value = address_value(data[:work_history][2][:address], 0)
        when 'City_8'
          field.field_value = address_value(data[:work_history][2][:address], 1)
        when 'ZIP_3'
          field.field_value = address_value(data[:work_history][2][:address], 3)
        when 'From_3'
          field.field_value = set_date_field(field, [:work_history, 2, :start_date], data)
        when 'To_5'
          field.field_value = set_date_field(field, [:work_history, 2, :start_date], data)

        when 'dochub_cb_2a9c64dd4c683c8c' # Liability Insurance CB Yes
          field.field_value = data[:liability_insurance_issues] == 'Yes'
        when 'dochub_cb_3b0949394101b2fc' # Liability Insurance CB No
          field.field_value = data[:liability_insurance_issues] == 'No'

        when 'dochub_cb_9aaab34ae869dafb' # Malpractice Claims CB Yes
          field.field_value = data[:malpractice_claims] == 'Yes'
        when 'dochub_cb_a6e21f00dac9dd5c' # Malpractice Claims CB No
          field.field_value = data[:malpractice_claims] == 'No'

        when 'dochub_cb_a5a04b6579a6f4af' # Health Impairments CB Yes
          field.field_value = data[:health_impairments] == 'Yes'
        when 'dochub_cb_46818711f1c4a4d0' # Health Impairments CB No
          field.field_value = data[:health_impairments] == 'No'

        when 'dochub_cb_fe520490fdc6b5f5' # Substance Abuse CB Yes
          field.field_value = data[:substance_abuse] == 'Yes'
        when 'dochub_cb_8cef1d4f82ec6426' # Substance Abuse CB No
          field.field_value = data[:substance_abuse] == 'No'

        when 'dochub_cb_4a735f0a5935aa76' # Criminal Conviction CB Yes
          field.field_value = data[:criminal_convictions] == 'Yes'
        when 'dochub_cb_d93b2c2b766f4e92' # Criminal Conviction CB No
          field.field_value = data[:criminal_convictions] == 'No'

        when 'dochub_cb_64075b1bd67d39ec' # Licensing Issues CB Yes
          field.field_value = data[:licensing_issues] == 'Yes'
        when 'dochub_cb_eb05ef09e62c481f' # Licensing Issues CB No
          field.field_value = data[:licensing_issues] == 'No'
        else
          next # Skips unsupported field
        end
      end

      doc.write(output_path.to_s)

      puts "File Saved in: #{output_path}"
    else
      raise 'No form fields found in the PDF.'
    end
  end

  private

  def time_value(time_data, position)
    time_data.split(' - ')[position]
  end

  def address_value(address_data, position)
    address_data.split(',')[position]
  end

  def coverage_valid_through_end_of_month?(data)
    valid_date_format!(data[:expiration_date])
    expiration_date = Date.strptime(data[:expiration_date], "%m/%d/%Y")
    last_day_of_month = Date.new(Date.today.year, Date.today.month, -1)

    expiration_date >= last_day_of_month
  rescue
    nil
  end

  def generate_unique_output_path(custom_file_name = nil)
    folder_path = generate_folder_path
   
    if custom_file_name.blank? 
      timestamp = Time.current.strftime('%Y%m%d%H%M%S')
      unique_id = SecureRandom.hex(4)
      custom_file_name = "Populated_#{timestamp}_#{unique_id}.pdf"
    end
   
    folder_path.join(custom_file_name)
  end

  def generate_folder_path
    folder_path = Rails.root.join('public', 'autopopulate_providers_output')
    FileUtils.mkdir_p(folder_path) unless Dir.exist?(folder_path)

    folder_path
  end

  def set_date_field(field, field_path, data)
    value = if field_path.is_a?(Array)
              field_path.reduce(data) { |memo, key| memo[key] }
            else
              data[field_path]
            end

    valid_date_format!(value)

    field.field_value = value
  end

  def valid_date_format!(date)
    return if date.nil?

    raise ArgumentError, "Invalid date format. Expected MM/DD/YYYY or MM/YYYY." unless date =~ /(0[1-9]|1[0-2])\/(\d{2}|\d{4})/
  end

  def validate_data(data)

    required_keys = %i[
      first_name last_name license_number graduation_date dental_school date_started
      office_name address office_city state zip phone_number
  ]

    # Check for missing keys
    missing_keys = required_keys - data.keys
    raise ArgumentError, "Missing keys: #{missing_keys.join(', ')}" unless missing_keys.empty?

    # Check for nil values
    nil_keys = required_keys.select { |key| data[key].nil? }
    raise ArgumentError, "Keys with nil values: #{nil_keys.join(', ')}" unless nil_keys.empty?

    data
  end
end

# Usage
# json_data = Rails.root.join('lib', 'data', 'json', 'provider.json’)
# template_path = Rails.root.join('public', 'templates', 'Careington Template.pdf')

# service = AutomationTool::PdfPopulatorService.new(template_path, json_data)
# service.call