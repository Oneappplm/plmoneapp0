require "application_system_test_case"

class HvhsDataTest < ApplicationSystemTestCase
  setup do
    @hvhs_datum = hvhs_data(:one)
  end

  test "visiting the index" do
    visit hvhs_data_url
    assert_selector "h1", text: "Hvhs data"
  end

  test "should create hvhs datum" do
    visit hvhs_data_url
    click_on "New hvhs datum"

    fill_in "Degree titles", with: @hvhs_datum.degree_titles
    fill_in "First name", with: @hvhs_datum.first_name
    fill_in "Last name", with: @hvhs_datum.last_name
    fill_in "License number", with: @hvhs_datum.license_number
    fill_in "License state", with: @hvhs_datum.license_state
    fill_in "Middle name", with: @hvhs_datum.middle_name
    fill_in "Npi", with: @hvhs_datum.npi
    fill_in "Office address line1", with: @hvhs_datum.office_address_line1
    fill_in "Office address line2", with: @hvhs_datum.office_address_line2
    fill_in "Office city", with: @hvhs_datum.office_city
    fill_in "Office mgr email", with: @hvhs_datum.office_mgr_email
    fill_in "Office mgr fax", with: @hvhs_datum.office_mgr_fax
    fill_in "Office mgr first name", with: @hvhs_datum.office_mgr_first_name
    fill_in "Office mgr last name", with: @hvhs_datum.office_mgr_last_name
    fill_in "Office mgr phone", with: @hvhs_datum.office_mgr_phone
    fill_in "Office state", with: @hvhs_datum.office_state
    fill_in "Office zip code", with: @hvhs_datum.office_zip_code
    fill_in "Phone number", with: @hvhs_datum.phone_number
    fill_in "Practice email address", with: @hvhs_datum.practice_email_address
    fill_in "Special type", with: @hvhs_datum.special_type
    fill_in "Taxonomy code", with: @hvhs_datum.taxonomy_code
    click_on "Create Hvhs datum"

    assert_text "Hvhs datum was successfully created"
    click_on "Back"
  end

  test "should update Hvhs datum" do
    visit hvhs_datum_url(@hvhs_datum)
    click_on "Edit this hvhs datum", match: :first

    fill_in "Degree titles", with: @hvhs_datum.degree_titles
    fill_in "First name", with: @hvhs_datum.first_name
    fill_in "Last name", with: @hvhs_datum.last_name
    fill_in "License number", with: @hvhs_datum.license_number
    fill_in "License state", with: @hvhs_datum.license_state
    fill_in "Middle name", with: @hvhs_datum.middle_name
    fill_in "Npi", with: @hvhs_datum.npi
    fill_in "Office address line1", with: @hvhs_datum.office_address_line1
    fill_in "Office address line2", with: @hvhs_datum.office_address_line2
    fill_in "Office city", with: @hvhs_datum.office_city
    fill_in "Office mgr email", with: @hvhs_datum.office_mgr_email
    fill_in "Office mgr fax", with: @hvhs_datum.office_mgr_fax
    fill_in "Office mgr first name", with: @hvhs_datum.office_mgr_first_name
    fill_in "Office mgr last name", with: @hvhs_datum.office_mgr_last_name
    fill_in "Office mgr phone", with: @hvhs_datum.office_mgr_phone
    fill_in "Office state", with: @hvhs_datum.office_state
    fill_in "Office zip code", with: @hvhs_datum.office_zip_code
    fill_in "Phone number", with: @hvhs_datum.phone_number
    fill_in "Practice email address", with: @hvhs_datum.practice_email_address
    fill_in "Special type", with: @hvhs_datum.special_type
    fill_in "Taxonomy code", with: @hvhs_datum.taxonomy_code
    click_on "Update Hvhs datum"

    assert_text "Hvhs datum was successfully updated"
    click_on "Back"
  end

  test "should destroy Hvhs datum" do
    visit hvhs_datum_url(@hvhs_datum)
    click_on "Destroy this hvhs datum", match: :first

    assert_text "Hvhs datum was successfully destroyed"
  end
end
