class WebscraperService < ApplicationService
	SCREENSHOT_FILENAME = 'screenshot.png'
	PDF_FILENAME = 'screenshot.pdf'
	PUBLIC_PATH = Rails.root.join('public', 'webscrape')

 attr_reader :crawler_folder

	def crawl
		begin
			initialize_folder_path!
			crawl!
			success!
		rescue => exception
			if crawler
				save_screenshot
			 crawler.quit()
			end

			error!(exception)
		end
	end

	def crawler
		if Rails.env.development?
			options = Selenium::WebDriver::Chrome::Options.new
		else
				# for heroku server
				# Webdrivers::Chromedriver.required_version = '117.0.5938.88'
				# Selenium::WebDriver::Chrome.path = ENV.fetch('GOOGLE_CHROME_BIN', nil)
				# options = Selenium::WebDriver::Chrome::Options.new(
				# 		prefs: { 'profile.default_content_setting_values.notifications': 2 },
				# 		binary: ENV.fetch('GOOGLE_CHROME_SHIM', nil)
				# )

				# for vps server
				# Webdrivers::Chromedriver.required_version = 'latest'
				options = Selenium::WebDriver::Chrome::Options.new(
						prefs: { 'profile.default_content_setting_values.notifications': 2 },
						binary: '/usr/bin/google-chrome'  # Use the correct path to Chrome
				)
		end

		# uncomment the following line to run headless else comment it out to run in browser
		options.add_argument('--headless')

		options.add_argument('--disable-gpu')
		options.add_argument('--no-sandbox')

		@crawler ||= Selenium::WebDriver.for :chrome, options: options
	end

	def crawl!
			nil
	end

	def save_screenshot
	  if crawler_folder_name == 'pals'
	    # Scroll to bottom and resize to full height for PALS
	    crawler.execute_script('window.scrollTo(0, document.body.scrollHeight);')
	    sleep 2
	    height = crawler.execute_script("return document.body.scrollHeight")
	    crawler.manage.window.resize_to(1024, height)
	  else
	    # Default behavior for all other scrapers
	    crawler.execute_script('window.scrollTo(0, 0);')
	    crawler.manage.window.resize_to(1024, 1024)
	  end

	  # Save screenshot
	  save_path = PUBLIC_PATH.join(crawler_folder_name, SCREENSHOT_FILENAME)
	  crawler.save_screenshot(save_path)

	  # Generate PDF from screenshot
	  pdf = Prawn::Document.new
	  png_path = Rails.root.join('public', 'webscrape', crawler_folder_name, 'screenshot.png')
	  pdf.image png_path, fit: [500, 500], position: :center

	  # Save PDF
	  pdf_filename = 'screenshot.pdf'
	  pdf_path = Rails.root.join('public', 'webscrape', crawler_folder_name, pdf_filename)
	  pdf.render_file pdf_path

	  # Create WebcrawlerLog or log output (if needed)
	  filepath = ['public', 'webscrape', crawler_folder_name, pdf_filename].join('/')
	  extension = File.extname(pdf_path)
	  crawl_type = crawler_folder_name.upcase
	  
	rescue => exception
	  # Log failure if an error occurs
	  WebcrawlerLog.create(
	    crawler_type: crawler_folder_name.upcase,
	    status: 'failed'
	  )
	  nil
	end

	def initialize_folder_path!
		FileUtils.mkdir_p(PUBLIC_PATH.join(crawler_folder_name))
		FileUtils.rm_f(PUBLIC_PATH.join(crawler_folder_name, SCREENSHOT_FILENAME))
	end

	def crawler_folder_name
		crawler_folder || 'crawler'
	end

	def success!
			{
					status: 'success',
					message: 'Scraping completed successfully!'
			}
	end

	def error! e
			{
					status: 'error',
					message: "An error occurred during scraping: #{e.message rescue e}"
			}
	end
end
