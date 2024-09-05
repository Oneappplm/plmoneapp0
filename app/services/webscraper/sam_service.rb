# frozen_string_literal: true

class Webscraper::SamService < WebscraperService
 attr_reader :encompass_id, :username, :password

 def initialize(encompass_id, username: "devs", password: "Test123!")
  @encompass_id   = encompass_id
  @username       = username
  @password       = password
  @crawler_folder = "sam"
 end

 def call
  crawl
 end

 def crawl!
  crawler.get('https://dwmha.webcvo.net/Index.asp') 
  sleep(5)

  # login
  crawler.find_element(:name, 'txtUserName').send_keys(username)
  crawler.find_element(:id, "txtPassword").send_keys(password)
  crawler.find_element(:xpath, "//a[@href='javascript:submitbutton()']").click
  
  # search by encompass id
  crawler.find_element(:id, 'txtSearchName').send_keys(encompass_id)
  crawler.find_element(:xpath, "//img[@src='../images/search.gif']").click
  
  # click the partitioner
  crawler.find_element(css: 'a[href^="ManageClient.asp"]').click

  # click SAM tab with href SAM%2Easp
  crawler.find_element(css: 'a[href^="SAM%2Easp"]').click
 
  # binding.break
  # sleep(5)
  # click button with id btnAutoCreateSamRecords
  # crawler.find_element(:id, "mainIframe")
  # crawler.find_element(css: 'input[id^="btnAutoCreateSamRecords"').click

  iframe = crawler.find_element(:xpath, "//iframe[contains(@src, 'sam/default.aspx')]")
  crawler.switch_to.frame(iframe)
  crawler.find_element(:id, "btnAutoCreateSamRecords").click

  # loop table records with tbody id tbodyNames
  tbody = crawler.find_element(id: 'tbodyNames')

  # Single TR
  # Get the first row (<tr>) within the tbody
  first_row = tbody.find_element(tag_name: 'tr')

  # Find the first cell (<td>) within the first row
  first_td = first_row.find_element(tag_name: 'td')

  # Click the first <td>
  # first_td.click

  # Wait for the input to be present and clickable
  # wait = Selenium::WebDriver::Wait.new(timeout: 20)
  # input_button = wait.until {
  #   element = crawler.find_element(xpath: '//input[@type="submit" and @id="btnEdit" and @name="btnPostBack" and @class="v10bk"]')
  #   element if element.displayed? && element.enabled?
  # }

  # Find the input button directly (will wait up to 20 seconds for it to appear)
  input_button = first_td.find_element(xpath: '//input[@type="submit" and @id="btnEdit" and @name="btnPostBack" and @class="v10bk"]')


  # Click the input button
  input_button.click
  # Single TR



  # Get all the rows (<tr>) within the tbody
  # rows = tbody.find_elements(tag_name: 'tr')

  
  save_screenshot
  

  crawler.quit()

  # sleep(5)


  # crawler.get("https://dwmha.webcvo.net/dotnetencompass/tabs/sam/default.aspx?pracid=ENC105093&key=bb1b34b5-665f-4a48-b82b-073b8f8f6d5d")
  # save_screenshot
  # crawler.quit()
 end

end
