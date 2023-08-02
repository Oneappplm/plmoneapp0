class ProvidersMissingFieldSubmissionsData < ApplicationRecord
  belongs_to :providers_missing_field_submission


  def is_state_id?
    self.data_key == 'state_id' || self.data_key == 'birth_state'
  end

  def get_state_name
    State.find_by(id: self.data_value)&.name
  rescue
    ''
  end

  def get_title(key)
    required_field_titles.each do |title_list|
     return title_list[0] if title_list.include?(key)
    end
    return ''
  end

  def get_document_title(key)
    required_documents.each do |title_list|
     return title_list[0] if title_list.include?(key)
    end
    return ''
  end

  def get_attribute_title(key)
    required_state_licenses_field_titles.each do |title_list|
     return title_list[0] if title_list.include?(key)
    end
    return ''
  end

  def required_documents
    [
     ['State License Copy', 'state_license_copy_file'],
     ['DEA Copy', 'dea_copy_file'],
     ['W9 Form', 'w9_form_file' ],
     ['Certificate of Insurance', 'certificate_insurance_file'],
     ['Drivers License', 'drivers_license_file' ],
     ['License Registered State', 'board_certification_file' ],
     ['CAQH App Copy', 'caqh_app_copy_file' ],
     ['Curriculum Vitae (CV)', 'cv_file' ],
     ['Telehealth License Copy', 'telehealth_license_copy_file'],
     ['Copy of Certificate', 'school_certificate']
   ]
  end

  # needed on notification page http://localhost:3000/enrollment-clients/:id?mode=notifications
  def required_field_titles()
    [
      ['First Name', 'first_name', 'text_field'],
      ['Last Name', 'last_name', 'text_field'],
      ['SSN', 'ssn', 'text_field'],
      ['Date of birth', 'birth_date', 'date_field'],
      ['Birth City', 'birth_city', 'text_field'],
      ['Birth State', 'birth_state', 'state_dropdown'],
      ['Address Line 1', 'address_line_1', 'text_field'],
      ['City', 'city','text_field'],
      ['State','state_id', 'state_dropdown'],
      ['Zip Code', 'zip_code', 'text_field'],
      ['Practitioner Type', 'practitioner_type', 'practitioner_dropdown'],
      ['Taxonomy', 'taxonomy', 'text_field'],
      ['Specialty', 'specialty', 'specialty_dropdown'],
      ['Client','enrollment_group_id','client_dropdown'],
    ]
  end

  def required_state_licenses_field_titles
    [
      ['State License Number', 'license_number', 'text_field'],
      ['License Effective Date', 'license_effective_date', 'date_field'],
      ['License Registration State', 'state_id', 'state_dropdown'],
      ['License Expiration Date', 'license_expiration_date', 'date_field']
    ]
  end
end