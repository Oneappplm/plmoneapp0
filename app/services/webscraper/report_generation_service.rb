# frozen_string_literal: true

class Webscraper::ReportGenerationService < WebscraperService
	attr_reader :encompass_id, :username, :password
	def initialize(encompass_id, username: "devs", password: "Test123!")
		@encompass_id = encompass_id
		@username = username
		@password = password
		@crawler_folder = 'report_generation'
	end

	def call
		crawl
	end

	def crawl!
		options = Selenium::WebDriver::Chrome::Options.new

	  # Uncomment the following line to run headless
	  options.add_argument('--headless')

	  options.add_argument('--disable-gpu')
	  options.add_argument('--no-sandbox')

	  @crawler ||= Selenium::WebDriver.for :chrome, options: options

		crawler.get('https://dwmha.webcvo.net/Index.asp')
		sleep(10)

		handle_alert_if_present

		# login
		crawler.find_element(:name, 'txtUserName').send_keys(username)
		crawler.find_element(:id, "txtPassword").send_keys(password)
		crawler.find_element(:xpath, "//a[@href='javascript:submitbutton()']").click

		# capture_full_page_screenshot_old(crawler, "screenshot.png")
		# save_screenshot
# binding.break
		# search by encompass id
		crawler.find_element(:id, 'txtSearchName').send_keys(encompass_id)
		crawler.find_element(:xpath, "//img[@src='../images/search.gif']").click

		# click the practitioner
		crawler.find_element(css: 'a[href^="ManageClient.asp"]').click

		# click View Profile
		crawler.find_element(css: 'a[href^="Profile.asp"]').click

		# Store the current window handle
  main_window = crawler.window_handle

		# Store the current window handles
  original_window_handles = crawler.window_handles

		# click Generate Profile button
		crawler.find_element(css: 'input[value="Generate Profile (.NET)"]').click

		# Wait for the new window to appear
  wait = Selenium::WebDriver::Wait.new(timeout: 10)
  wait.until { crawler.window_handles.size > original_window_handles.size }

		# Get the new window handle
  new_window_handle = (crawler.window_handles - original_window_handles).first

  # Switch to the new window
  crawler.switch_to.window(new_window_handle)

		# click radio button with id rblVerifiedProfileVersion_2
		crawler.find_element(:id, 'rblVerifiedProfileVersion_2').click

		# click checkbox with id cbSelectAll
		crawler.find_element(:id, 'cbSelectAll').click

		# click button with id btnQueue
		crawler.find_element(:id, 'btnQueue').click


		capture_bottom_page_screenshot(crawler, save_path)
		convert_png_to_pdf(save_path, save_path_pdf)
		# sleep(2)
		crawler.quit()
	end

	private

	def folder_path
	  path = Rails.root.join('public', 'webscrape', 'report_generation')
	end

  def save_path
    folder_path.join('screenshot.png')
  end

  def save_path_pdf
    folder_path.join('screenshot.pdf')
  end
  
	def capture_bottom_page_screenshot(driver, file_path)
		total_height = driver.execute_script('return document.body.scrollHeight')
		viewport_height = driver.execute_script('return window.innerHeight')

		# Scroll to the bottom of the page
		driver.execute_script('window.scrollTo(0, document.body.scrollHeight);')
		sleep(5) # Give the page time to load

		# Capture the screenshot of the current viewport
		screenshot = driver.screenshot_as(:png)
		image = ChunkyPNG::Image.from_blob(screenshot)

		# Determine the height of the bottom part to capture
		bottom_height = total_height % viewport_height
		if bottom_height == 0
				bottom_height = viewport_height
		end

		# Create a blank image with the height of the bottom part
		stitched_image = ChunkyPNG::Image.new(image.width, bottom_height, ChunkyPNG::Color::WHITE)

		# Paste the current viewport into the final image
		stitched_image.replace!(image.crop(0, image.height - bottom_height, image.width, bottom_height), 0, 0)

		# Save the final image
		stitched_image.save(file_path)
	end

	# Method to convert a PNG image to PDF
	def convert_png_to_pdf(png_path, pdf_path)
		Prawn::Document.generate(pdf_path) do |pdf|
				pdf.image png_path, fit: [pdf.bounds.width, pdf.bounds.height]
		end
	end

	def handle_alert_if_present
	  begin
	    alert = Selenium::WebDriver::Wait.new(timeout: 5).until { crawler.switch_to.alert }
	    alert.accept # or alert.dismiss if you want to dismiss the alert instead of accepting it
	  rescue Selenium::WebDriver::Error::NoAlertPresentError
	    # No alert present, continue
	  end
	end
end
