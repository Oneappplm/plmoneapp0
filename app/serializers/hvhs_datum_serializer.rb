class HvhsDatumSerializer < ActiveModel::Serializer
  attributes :id, :npi, :first_name, :middle_name, :last_name, :degree_titles, :office_address_line1, :office_address_line2, :office_city, :office_state, :office_zip_code, :phone_number, :practice_email_address, :office_mgr_email, :office_mgr_fax, :office_mgr_first_name, :office_mgr_last_name, :office_mgr_phone, :special_type, :taxonomy_code, :license_number, :license_state
end
