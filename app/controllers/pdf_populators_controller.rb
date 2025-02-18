class PdfPopulatorsController < ApplicationController
 include PdfPopulatorsHelper
 
 def index
  # @pdf_files = Dir[Rails.root.join('public', 'populated_pdf', '*.pdf')]
  if params.dig(:provider_id).present? && params.dig(:pdf_form).present?
     provider = Provider.find_by_id params.dig(:provider_id)
     data = format_data
    
     provider.attributes.each do |key, value|
      data[key.to_sym] = value if data.key?(key.to_sym) # Ensure the key exists in data
     end
     
     custom_file_name = "#{provider.last_name}_#{provider.middle_name}_#{provider.first_name}_#{params.dig(:pdf_form)}_#{Time.current.strftime("%Y-%m-%d %H%M%S")}.pdf"
     service = AutomationTool::PdfPopulatorService.new(pdf_sample_template(params.dig(:pdf_form)), data, params.dig(:pdf_form), custom_file_name)
     service.call
    
     if File.exist?(service.output_path)
      send_file service.output_path, type: 'application/pdf', disposition: 'attachment'
     else
      render plain: "File not found", status: :not_found
     end
  end
 end

 def populate_data
  if params.dig(:auto_populate_data).present?
    data = eval(params[:"json-data"])
    service = AutomationTool::PdfPopulatorService.new(pdf_sample_template, data)
    service.call

    redirect_to pdf_populators_path, notice: "Auto Populate data has been successfully completed."
  end
 end

 protected
 def format_data
  {
  first_name: "Jarrod",
  middle_initial: "M",
  last_name: "Lee",
  dob: "11/11/1994",
  npi: "1679209381",
  license_number: "DS0000012013",
  graduation_date: "06/2022",
  dental_school: "Meharry Medical College",
  specialty: "General Dentist",
  date_started: "04/01/2024",
  office_name: "Hintz and Oakley Family Dentistry",
  address: "120 West Jackson Street",
  office_city: "Cookeville",
  state: "TN",
  zip: "38501",
  tax_id: "47-1611765",
  phone_number: "931-526-5460",
  fax_number: "931-526-5459",
  ada_compliance: "Yes",
  accepting_new_patients: "Yes",
  office_hours: {
    monday: "8:00 AM - 5:00 PM",
    tuesday: "7:30 AM - 5:00 PM",
    wednesday: "7:30 AM - 5:00 PM",
    thursday: "7:30 AM - 5:00 PM",
    friday: "8:00 AM - 5:00 PM"
  },
  board_certified: "Yes",
  hospital_privileges: "No",
  sedation_privileges: "Nitrous Oxide",
  w9_included: true,
  malpractice_insurance: true,
  dea_certificate: false,
  liability_coverage: {
    amount: "$1,000,000 per occurrence",
    expiration_date: "12/31/2024"
  },
   work_history: [
    {
     practice_name: "Hintz and Oakley Family Dentistry",
     address: "120 West Jackson Street, Cookeville, TN, 38501",
     start_date: "04/2024",
     end_date: nil
    },
    {
     practice_name: "Open Door Dental",
     address: "112 E 1st St, Crossville, TN, 38555",
     start_date: "01/2024",
     end_date: "03/2024"
    },
    {
     practice_name: "Dr. Darryl G. Smith, DDS",
     address: "805 Webb Ave, Crossville, TN, 38555",
     start_date: "08/2022",
     end_date: "11/2023"
    }
   ],
   attestation_questions: {
    liability_insurance_issues: "No",
    malpractice_claims: "No",
    health_impairments: "No",
    substance_abuse: "No",
    criminal_convictions: "No",
    licensing_issues: "No"
   }
  }  
 end
end
