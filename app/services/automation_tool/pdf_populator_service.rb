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

        # for guardian form
        when '232791939', '232791982'
          field.field_value = "#{data[:first_name]} #{data[:middle_initial]} #{data[:last_name]}"
        when 'Full Names', '232791938', 'Type or Print Name', 'ApplicantName1', 'Name', 'Name printed'
          field.field_value = "#{data[:first_name]} #{data[:middle_initial]} #{data[:last_name]}"
        when 'Degree', 'Degree Earned', 'Degree', 'Degree9a', 'Degrees', 'Degree Awarded'
          field.field_value = "#{data[:degree]}"
        when 'Contact Email', 'Email', 'EMail Address1c', 'Email address', 'EMail Address'
          field.field_value = data[:email_address]
        when 'Street address 1', 'Street1c', 'Street Address'
          field.field_value = "#{data[:address_line_1]}"
        when 'Street address 2', 'Street Address_2'
          field.field_value = "#{data[:address_line_2]}"
        when 'State', 'State_3', 'State_6', 'State_7', 'State1c', 'State'
          field.field_value = "#{data[:state_id]}"
        when '232791942', 'Zip', 'ZipCode1c', 'ZIP', 'Text99'
          field.field_value = "#{data[:zip_code]}"
        # when 'From', 'undefined_3'
        when 'From'
          if data[:date_started].is_a?(String)
            # Convert the string into a Date object first
            date_started = Date.parse(data[:date_started]) rescue nil
            field.field_value = date_started.strftime('%m') if date_started
          else
            field.field_value = data[:date_started].strftime('%m') if data[:date_started]
          end
        # when 'To', 'undefined_4'
        when 'To'
          if data[:date_ended].is_a?(String)
            # Convert the string into a Date object first
            date_ended = Date.parse(data[:date_ended]) rescue nil
            field.field_value = date_ended.strftime('%m') if date_ended
          else
            field.field_value = data[:date_ended].strftime('%m') if data[:date_ended]
          end
        when 'Number'
          field.field_value = "#{data[:telehealth_license_number]}"
        when 'Status', 'Status_2', 'Status_5', 'Status_6'
          field.field_value = "#{data[:status]}"
        # when 'Issue Date', 'Issue Date_2','undefined_5', 'undefined_6', 'undefined_17', 'undefined_18',
        #   field.field_value = "#{data[:liability_issue_date]}"
        when 'Expiration Date', 'Expiration Date_4', 'undefined_7', 'undefined_8', 'undefined_19', 'undefined_20'
          field.field_value = "#{data[:liability_expiration_date]}" if data[:liability_expiration_date].present?
        when 'Number_2', 'Illinois Professional License Number'
          field.field_value = "#{data[:license_number]}"
        when 'Number_3', 'Number_4', 'Board Certification Number - 1'
          field.field_value = "#{data[:board_certificate_number]}"
        when 'Issue Date_5', 'Issue Date_6', 'undefined_21', 'undefined_22', 'undefined_25', 'undefined_26', 'date certified1.11.0', 'Date Certified Year'
          field.field_value = "#{data[:board_effective_date]}" if data[:board_effective_date].present?
        when 'Expiration Date_5', 'Expiration Date_6', 'undefined_23', 'undefined_24', 'undefined_27', 'undefined_28', 'date exp. 1.11.111.4', 'Expiration Year 11.22'
          field.field_value = "#{data[:board_expiration_date]}" if data[:board_expiration_date].present?
        when 'Name of Board', 'Name and address of issuing boardRow1.0.0'
          field.field_value = "#{data[:board_name]}"
        when 'Certification Date'
          field.field_value = "#{data[:board_recertification_date]}"
        when 'Expiration Date_10'
          field.field_value = "#{data[:board_expiration_date]}"

        when 'Institution Name', 'Complete School Name', 'Complete school name and street address.0', 'Month of start'
          field.field_value = "#{data[:prof_medical_school_name]}"
        when 'From_2', 'undefined_54'
          if data[:prof_medical_start_date].is_a?(String)
            prof_medical_start_date = Date.parse(data[:prof_medical_start_date]) rescue nil
            field.field_value = prof_medical_start_date.strftime('%m') if prof_medical_start_date
          else
            field.field_value = data[:prof_medical_start_date].strftime('%m') if data[:prof_medical_start_date]
          end
        when 'Address_4'
          field.field_value = "#{data[:prof_medical_school_address]}"
        when 'City_4'
          field.field_value = "#{data[:prof_medical_school_city]}"
        when 'State_14', 'State_4'
          field.field_value = "#{data[:prof_medical_school_state_id]}"
        when 'Zip_5'
          field.field_value = "#{data[:prof_medical_school_zipcode]}"
        when 'Country if nonUS'
          field.field_value = "#{data[:prof_medical_school_country]}"

        when 'DegreesCertification Received'
          field.field_value = "#{data[:prof_medical_school_degree_awarded]}"
        when 'Facility Name', 'Facility name.0'
          field.field_value = "#{data[:facility_name]}"
        when 'Address_13', 'Complete address.3.1.1.1.0'
          field.field_value = "#{data[:admitting_facility_address_line1]} #{data[:admitting_facility_address_line2]} #{data[:admitting_facility_city]} #{data[:admitting_facility_state]}"

        when 'Complete school name and street address.0'
          field.field_value = "#{data[:prof_medical_school_address]} #{data[:prof_medical_school_city]} #{data[:prof_medical_school_state_id]} #{data[:prof_medical_school_zipcode]} #{data[:prof_medical_school_country]}"

        when 'First Name', 'text_firstname', 'txt_firstname', 'text_15hdnp', '232791939', 'First', 'FirstName', 'First'
          field.field_value = data[:first_name]
        when 'Middle Initial', 'text_middlename', 'txt_middlename', 'Middle', 'MI', 'Middle'
          field.field_value = data[:middle_initial]
        when 'Last Name', 'text_lastname', 'txt_lastname', 'text_14xnba', 'LastName', 'Last Name include suffix Jr Sr III.0'
          field.field_value = data[:last_name]
        when 'Suffix'
          field.field_value = data[:suffix]

        when 'Date of  birth', 'text_23giep', 'Birth Date', 'BirthDate', 'Birth date  Month', 'Birth date  DAY', 'Birth date  year', 'Text95'
          dob_date = data[:dob].is_a?(Date) ? data[:dob] : Date.parse(data[:dob])

          case field.field_name
          when 'Birth date  Month'
            field.field_value = dob_date.strftime('%m')
          when 'Birth date  DAY'
            field.field_value = dob_date.strftime('%d')
          when 'Birth date  year'
            field.field_value = dob_date.strftime('%Y')
          else
            field.field_value = dob_date.strftime('%m/%d/%Y')
          end

        when 'National Provider Identifier Individual NPI', '232791941', 'National Provider Identifier #', 'National Provider Identification Number NPI', 'NPID formerly UPIN', 'undefined_2'
          field.field_value = data[:npi]
        when 'Social Security Number', 'SSN', 'Text94'
          field.field_value = data[:ssn]
        when 'dochub_cb_d65213f80dcc44fc', 'Primary specialty', 'Specialty I', 'Specialty' # General Dentist Checkbox
          field.field_value = data[:specialty] == 'General Dentist'
        when 'State Dental License', 'License'
          field.field_value = data[:license_number]
        when 'Graduation Date Month  Year'
          field.field_value = set_date_field(field, :graduation_date, data)
        when 'C Home Address'
          field.field_value = "#{data[:address_line_1]} #{data[:address_line_2]}"
        when 'City', 'City1c', 'Text85','City'
          field.field_value = "#{data[:city]}"
        when 'D Home Telephone Number',  'telephone.0.0'
          field.field_value = "#{data[:telephone_number]}"
        when 'Place of birth', 'City', 'State', 'Birth place', 'Place of Birth'
          field.field_value = "#{data[:birth_city]} #{data[:birth_state]}"
        when 'checkbox', 'Gender'
          field.field_value = "#{data[:gender]}"
        when 'State_4a'
          field.field_value = "#{data[:license_state_id]}"
        when 'Exp Date4'
          field.field_value = "#{data[:license_state_expiration_date]}"
        when 'Medicare Unique Provider ID UPIN'
          field.field_value = "#{data[:medicare_provider_number]}"
        when 'Medicaid ID'
          field.field_value = "#{data[:medicaid_provider_number]}"
        when 'Carrier'
          field.field_value = "#{data[:prof_liability_carrier_name]}"
        when 'StreetAddress7'
          field.field_value = "#{data[:prof_liability_address]}"
        when 'Policy Number'
          field.field_value = "#{data[:prof_liability_policy_number]}"
        when 'Original Effective Date_28a'
          field.field_value = "#{data[:prof_liability_effective_date]}"
        when 'Expiration Date_68a'
          field.field_value = "#{data[:prof_liability_expiration_date]}"
        when 'Occurence8a'
          field.field_value = "#{data[:prof_liability_coverage_amount]}"
        when 'Aggregate_28a'
          field.field_value = "#{data[:prof_liability_coverage_amount_aggregate]}"

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
        
        when 'Address', '1', 'Home street address', 'Text96'
          if field.field_type == :Tx  # Only populate if it's a text field
            full_address = "#{data[:address]}, #{data[:office_city]}, #{data[:state]}, #{data[:zip]}"
            max_len = field[:MaxLen] || 999
            field.field_value = full_address[0, max_len]
          end

        when 'City_3', 'Clinical Practice City'
          field.field_value = data[:office_city]
        when 'State_6'
          field.field_value = data[:state]
        when 'ZIP Code', 'Text86'
          field.field_value = data[:zip]
        when 'Tax ID  Required'
          field.field_value = data[:tax_id]

        when 'Tel No', 'Office Telephone #', 'telephone.0.1.0', 'Phone Number'
          field.field_value = data[:phone_number]
        when 'Fax No', 'Text98'
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
        when 'Practice NameInstitution', 'Employer', 'Name of Current PracticeEmployer', 'Current work place', 'Name of primary practiceaffiliation or clinic', 'Institution'
          field.field_value = data[:work_history][0][:practice_name]
        when 'Address_4', 'Address_6', 'Address_20', 'StreetAddress16', 'City_2'
          field.field_value = address_value(data[:work_history][0][:address], 0)
        when 'City_6', 'City16'
          field.field_value = address_value(data[:work_history][0][:address], 1)
        when 'ZIP', 'zipcode16'
          field.field_value = address_value(data[:work_history][0][:address], 3)
        when 'From', 'Date MMYYYY From', 'undefined_58'
          field.field_value = set_date_field(field, [:work_history, 0, :start_date], data)
        when 'To_3', 'to_8', 'undefined_59'
          field.field_value = set_date_field(field, [:work_history, 0, :end_date], data)
        when 'Practice NameInstitution_2', 'Employer_2', 'Name of Prior PracticeEmployer', 'Previous work place', 'Name of secondary practiceaffiliation or clinic', 'Text137'
          field.field_value = data[:work_history][1][:practice_name]
        when 'Address_5', 'StreetAddress16a'
          field.field_value = address_value(data[:work_history][1][:address], 0)
        when 'City_7', 'City16a'
          field.field_value = address_value(data[:work_history][1][:address], 1)
        when 'ZIP_2', 'zipcode16a'
          field.field_value = address_value(data[:work_history][1][:address], 3)
        when 'From_2', 'Date MMYYYY From_2', 'undefined_60', 'From mmyy', 'Time in this employment From_2'
          # field.field_value = set_date_field(field, [:work_history, 1, :start_date], data)
          set_date_field(field, [:work_history, 1, :start_date], data)
        when 'To_4', 'to_9', 'undefined_61', 'To mmyy_01', 'to'
          # field.field_value = set_date_field(field, [:work_history, 1, :end_date], data)
          set_date_field(field, [:work_history, 1, :end_date], data)
        when 'Practice NameInstitution_3', 'Employer_3', 'Name of Prior PracticeEmployer_2', 'Previous work place_2', 'Institution_2'
          field.field_value = data[:work_history][2][:practice_name]
        when 'Address_6', 'StreetAddress16b'
          field.field_value = address_value(data[:work_history][2][:address], 0)
        when 'City_8', 'City16b'
          field.field_value = address_value(data[:work_history][2][:address], 1)
        when 'ZIP_3', 'zipcode16b'
          field.field_value = address_value(data[:work_history][2][:address], 3)
        when 'From_3', 'Date MMYYYY From_3', 'undefined_62', 'From mmyy_2', 'Time in this employment From_3'
          # field.field_value = set_date_field(field, [:work_history, 2, :start_date], data)
          set_date_field(field, [:work_history, 2, :start_date], data)
        when 'To_5', 'to_10', 'undefined_63', 'To mmyy_2-1', 'to_2'
          # field.field_value = set_date_field(field, [:work_history, 2, :end_date], data)
          set_date_field(field, [:work_history, 2, :end_date], data)
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

    max_len = field[:MaxLen] || 999 # If no max length is provided, assume no limit
    value = data[field.field_name.to_sym] || ''
    
    # Ensure value doesn't exceed max length
    if value.length > max_len
      value = value[0, max_len]  # Truncate the value to fit the max length
    end
    
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