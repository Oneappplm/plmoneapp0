require "application_system_test_case"

class HelpCodesTest < ApplicationSystemTestCase
  setup do
    @help_code = help_codes(:one)
  end

  test "visiting the index" do
    visit help_codes_url
    assert_selector "h1", text: "Help codes"
  end

  test "should create help code" do
    visit help_codes_url
    click_on "New help code"

    fill_in "Category", with: @help_code.category
    fill_in "Code", with: @help_code.code
    fill_in "Description", with: @help_code.description
    click_on "Create Help code"

    assert_text "Help code was successfully created"
    click_on "Back"
  end

  test "should update Help code" do
    visit help_code_url(@help_code)
    click_on "Edit this help code", match: :first

    fill_in "Category", with: @help_code.category
    fill_in "Code", with: @help_code.code
    fill_in "Description", with: @help_code.description
    click_on "Update Help code"

    assert_text "Help code was successfully updated"
    click_on "Back"
  end

  test "should destroy Help code" do
    visit help_code_url(@help_code)
    click_on "Destroy this help code", match: :first

    assert_text "Help code was successfully destroyed"
  end
end
