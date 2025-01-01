# frozen_string_literal: true
class Webscraper::QualityAuditService < WebscraperService
  attr_reader :username, :password, :encompass_id, :data

  def initialize(encompass_id, data, username: "Kent", password: "Kenneth2!")
    @encompass_id = encompass_id
    @username = username
    @password = password
    @data = data # JSON Data
    @crawler_folder = 'quality_audit'
  end

  def call
    crawl
  end

  def crawl!
    crawler.get('https://metlife.webcvo.net/')
    sleep(5)
    select_frame(crawler)

    # login
    crawler.find_element(:name, 'txtUserName').send_keys(username)
    sleep(2)
    crawler.find_element(:id, 'txtPassword').send_keys(password)
    sleep(2)
    crawler.find_element(:xpath, "//a[@href='javascript:submitbutton()']").click
    sleep(5)

    # Search by encompass id
    crawler.find_element(:id, 'txtSearchName').send_keys(encompass_id)
    crawler.find_element(:xpath, "//img[@src='../images/search.gif']").click
    sleep(5)

    # click the practitioner
    row = crawler.find_element(:xpath, "//tr[td[contains(text(), '#{encompass_id}')]]")
    row.find_element(:xpath, "//a[starts-with(@href, 'ManageClient.asp?')]").click
    sleep(5)

    # click liability tab
    liability_tab = crawler.find_element(:xpath, "//a[@href='SecXII%2Easp']")
    liability_tab.click
    sleep(3)

    # Show record
    crawler.find_element(:name, 'RecordNo').click
    sleep(5)
    carrier_name = crawler.find_element(:name, 'txtCarrierName1')

    if carrier_name.displayed? && carrier_name.attribute('value').present?
      quality_audit(crawler, 0) # To get the first Quality Audit btn the pointer is set to 0

      # Select request method
      request_method_dropdown = crawler.find_element(:name, 'SendMethod')
      request_method = Selenium::WebDriver::Support::Select.new(request_method_dropdown)
      request_method.select_by(:text, data[:request_method])

      # Send Request
      send_request_btn = crawler.find_element(:xpath, "//input[@value='Send Request']")
      send_request_btn.click if send_request_btn.displayed?
      sleep(5)

      #  Save Request
      save_request_btn = crawler.find_element(:xpath, "//input[@value='Save Request']")
      if save_request_btn.displayed?
        save_request_btn.click
        sleep(3)

        switch_window(crawler, crawler.window_handles.last)
        sleep(5)

        save_btn = crawler.find_element(:xpath, "//input[@value='Save Request']")
        save_btn.click
        sleep(3)

        switch_window(crawler, crawler.window_handles.last) # Switch back to Quality Audit Window
        sleep(5)
      end

      fill_out_verification_form(crawler, data[:verification])

      # Set Audit Status (Pass/Fail)
      set_audit_status(crawler)

      switch_to_main_window(crawler)
    end

    if data[:verify_claims_history] == 'yes'
      # This will do the same steps above in the claims history page
      quality_audit(crawler, 1) # To get the last Quality Audit button
      fill_out_verification_form(crawler, data[:claims_history])

      # Set Audit Status (Pass/Fail)
      set_audit_status(crawler)

      switch_to_main_window(crawler)
    else
      # Skip RVA After
      skip_btn = crawler.find_element(:xpath, "//input[@value='Skip RVA' and contains(@onclick, 'ClaimsHistory')]")
      skip_btn.click if skip_btn.displayed?
    end

    save_screenshot
    sleep(1)

    crawler.quit
  end

  private

  def select_frame(crawler)
    frame = crawler.find_element(:name, 'IndexFrm')
    crawler.switch_to.frame(frame)

    crawler
  end

  def switch_window(crawler, window)
    crawler.switch_to.window(window)

    crawler
  end

  def switch_to_main_window(crawler)
    crawler.close
    switch_window(crawler, crawler.window_handles.first)
    select_frame(crawler)
  end

  def quality_audit(crawler, pointer)
    quality_audit_btn = crawler.find_elements(:xpath, "//input[@value='Quality Audit']")[pointer]
    quality_audit_btn.click
    sleep(5)

    switch_window(crawler, crawler.window_handles.last)
    sleep(5)
  end

  def fill_out_verification_form(crawler, field_values)
    source_dropdown = crawler.find_element(:name, 'SourceName')
    # Fill up verification form
    if source_dropdown.enabled?
      source_name = Selenium::WebDriver::Support::Select.new(source_dropdown)
      source_name.select_by(:text, field_values[:source_name])
    else
      puts "The source dropdown is disabled and cannot be interacted with."
    end

    # Set source date
    crawler.find_element(:name, 'SourceDate').send_keys(field_values[:source_date])

    # Select verification status
    status_dropdown = crawler.find_element(:name, 'Status')
    status = Selenium::WebDriver::Support::Select.new(status_dropdown)
    status.select_by(:text, field_values[:status])

    # Select adverse action
    adverse_action_dropdown = crawler.find_element(:name, 'AdverseAction')
    adverse_action = Selenium::WebDriver::Support::Select.new(adverse_action_dropdown)
    adverse_action.select_by(:text, field_values[:adverse_action])

    # Click Save Verification
    save_verification_btn = crawler.find_element(:name, 'SaveVerification')
    save_verification_btn.click if save_verification_btn.displayed?
    sleep(5)
  end

  def set_audit_status(crawler)
    pass_radio = crawler.find_element(xpath: "//input[@type='radio' and following-sibling::text()[normalize-space()='Pass']]")
    if pass_radio.displayed?
      pass_radio.click
      crawler.find_element(:name, 'SaveAudit').click
      sleep(5)
    end
  end
end
