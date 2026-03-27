require "test_helper"

class HelpCodesControllerTest < ActionDispatch::IntegrationTest
  
  setup do
    @help_code = help_codes(:one)
  end

  test "should get index" do
    get help_codes_url
    assert_response :success
  end

  test "should get new" do
    get new_help_code_url
    assert_response :success
  end

  test "should create help_code" do
    assert_difference("HelpCode.count") do
      post help_codes_url, params: { help_code: { category: @help_code.category, code: @help_code.code, description: @help_code.description } }
    end

    assert_redirected_to help_code_url(HelpCode.last)
  end

  test "should show help_code" do
    get help_code_url(@help_code)
    assert_response :success
  end

  test "should get edit" do
    get edit_help_code_url(@help_code)
    assert_response :success
  end

  test "should update help_code" do
    patch help_code_url(@help_code), params: { help_code: { category: @help_code.category, code: @help_code.code, description: @help_code.description } }
    assert_redirected_to help_code_url(@help_code)
  end

  test "should destroy help_code" do
    assert_difference("HelpCode.count", -1) do
      delete help_code_url(@help_code)
    end

    assert_redirected_to help_codes_url
  end
end
