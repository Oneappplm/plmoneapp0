require "test_helper"

class HvhsDataControllerTest < ActionDispatch::IntegrationTest
  setup do
    @hvhs_datum = hvhs_data(:one)
  end

  test "should get index" do
    get hvhs_data_url
    assert_response :success
  end

  test "should get new" do
    get new_hvhs_datum_url
    assert_response :success
  end

  test "should create hvhs_datum" do
    assert_difference("HvhsDatum.count") do
      post hvhs_data_url, params: { hvhs_datum: { degree_titles: @hvhs_datum.degree_titles, first_name: @hvhs_datum.first_name, last_name: @hvhs_datum.last_name, license_number: @hvhs_datum.license_number, license_state: @hvhs_datum.license_state, middle_name: @hvhs_datum.middle_name, npi: @hvhs_datum.npi, office_address_line1: @hvhs_datum.office_address_line1, office_address_line2: @hvhs_datum.office_address_line2, office_city: @hvhs_datum.office_city, office_mgr_email: @hvhs_datum.office_mgr_email, office_mgr_fax: @hvhs_datum.office_mgr_fax, office_mgr_first_name: @hvhs_datum.office_mgr_first_name, office_mgr_last_name: @hvhs_datum.office_mgr_last_name, office_mgr_phone: @hvhs_datum.office_mgr_phone, office_state: @hvhs_datum.office_state, office_zip_code: @hvhs_datum.office_zip_code, phone_number: @hvhs_datum.phone_number, practice_email_address: @hvhs_datum.practice_email_address, special_type: @hvhs_datum.special_type, taxonomy_code: @hvhs_datum.taxonomy_code } }
    end

    assert_redirected_to hvhs_datum_url(HvhsDatum.last)
  end

  test "should show hvhs_datum" do
    get hvhs_datum_url(@hvhs_datum)
    assert_response :success
  end

  test "should get edit" do
    get edit_hvhs_datum_url(@hvhs_datum)
    assert_response :success
  end

  test "should update hvhs_datum" do
    patch hvhs_datum_url(@hvhs_datum), params: { hvhs_datum: { degree_titles: @hvhs_datum.degree_titles, first_name: @hvhs_datum.first_name, last_name: @hvhs_datum.last_name, license_number: @hvhs_datum.license_number, license_state: @hvhs_datum.license_state, middle_name: @hvhs_datum.middle_name, npi: @hvhs_datum.npi, office_address_line1: @hvhs_datum.office_address_line1, office_address_line2: @hvhs_datum.office_address_line2, office_city: @hvhs_datum.office_city, office_mgr_email: @hvhs_datum.office_mgr_email, office_mgr_fax: @hvhs_datum.office_mgr_fax, office_mgr_first_name: @hvhs_datum.office_mgr_first_name, office_mgr_last_name: @hvhs_datum.office_mgr_last_name, office_mgr_phone: @hvhs_datum.office_mgr_phone, office_state: @hvhs_datum.office_state, office_zip_code: @hvhs_datum.office_zip_code, phone_number: @hvhs_datum.phone_number, practice_email_address: @hvhs_datum.practice_email_address, special_type: @hvhs_datum.special_type, taxonomy_code: @hvhs_datum.taxonomy_code } }
    assert_redirected_to hvhs_datum_url(@hvhs_datum)
  end

  test "should destroy hvhs_datum" do
    assert_difference("HvhsDatum.count", -1) do
      delete hvhs_datum_url(@hvhs_datum)
    end

    assert_redirected_to hvhs_data_url
  end
end
