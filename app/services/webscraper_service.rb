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
		options.add_argument('--window-size=1024,768')

		@crawler ||= Selenium::WebDriver.for :chrome, options: options
	end

	def crawl!
			nil
	end

	def save_screenshot
	  if crawler_folder_name == 'pals'
	    crawler.execute_script('window.scrollTo(0, document.body.scrollHeight);')
	    sleep 2
	    height = crawler.execute_script("return document.body.scrollHeight")
	    crawler.manage.window.resize_to(1024, height)
	  else
	    crawler.execute_script('window.scrollTo(0, 0);')
	    crawler.manage.window.resize_to(1024, 1024)
	  end

	  # Define base paths
	  base_path = Rails.root.join('public', 'webscrape', crawler_folder_name)
	  FileUtils.mkdir_p(base_path) unless Dir.exist?(base_path)

	  screenshot_path = base_path.join('screenshot.png')
	  pdf_path        = base_path.join('screenshot.pdf')

	  # === Step 1: Save screenshot
	  crawler.save_screenshot(screenshot_path)

	  # === Step 2: Convert screenshot to PDF
	  pdf = Prawn::Document.new
	  pdf.image screenshot_path, fit: [500, 500], position: :center
	  pdf.render_file(pdf_path)

	  # === Step 3: Log to database or attach (if required)
	  WebcrawlerLog.create!(
	    crawler_type: crawler_folder_name.upcase,
	    file_path: pdf_path.to_s.gsub(Rails.root.to_s + '/', ''),
	    status: 'success'
	  )

	  # === Step 4: Cleanup temporary files
	  [screenshot_path, pdf_path].each do |path|
	    if File.exist?(path)
	      File.delete(path)
	      Rails.logger.info("🗑️ Deleted temp file: #{path}")
	    else
	      Rails.logger.info("⚠️ Temp file not found: #{path}")
	    end
	  end

	rescue => e
	  WebcrawlerLog.create(
	    crawler_type: crawler_folder_name.upcase,
	    status: 'failed'
	  )
	  Rails.logger.error("❌ Screenshot failed for #{crawler_folder_name}: #{e.message}")
	  nil
	end

# <<<<<<< HEAD
# 	def folder_path
# 		PUBLIC_PATH.join(crawler_folder_name)
# 	end

# 	def save_path
# 		PUBLIC_PATH.join(crawler_folder_name, SCREENSHOT_FILENAME)
# =======
	def save_oig_screenshot
	  # === Step 0: Calculate full page size
	  scroll_height = crawler.execute_script(<<~JS)
	    return Math.max(
	      document.body.scrollHeight,
	      document.documentElement.scrollHeight,
	      document.body.offsetHeight,
	      document.documentElement.offsetHeight,
	      document.body.clientHeight,
	      document.documentElement.clientHeight
	    );
	  JS

	  scroll_width = crawler.execute_script(<<~JS)
	    return Math.max(
	      document.body.scrollWidth,
	      document.documentElement.scrollWidth,
	      document.body.offsetWidth,
	      document.documentElement.offsetWidth,
	      document.body.clientWidth,
	      document.documentElement.clientWidth
	    );
	  JS

	  # Scroll to top before resize (important)
	  crawler.execute_script('window.scrollTo(0, 0);')
	  sleep 0.3

	  # Resize browser to FULL page
	  crawler.manage.window.resize_to(scroll_width, scroll_height)
	  sleep 0.5

	  # === Step 1: Define base paths
	  base_path = Rails.root.join('public', 'webscrape', crawler_folder_name)
	  FileUtils.mkdir_p(base_path) unless Dir.exist?(base_path)

	  screenshot_path = base_path.join('screenshot.png')
	  pdf_path        = base_path.join('screenshot.pdf')

	  # === Step 2: Save FULL PAGE screenshot
	  crawler.save_screenshot(screenshot_path)

	  # === Step 3: Add timestamp watermark
	  human_date = Time.current.strftime("%Y-%m-%d, %I:%M %p")

	  image = MiniMagick::Image.open(screenshot_path)
	  image.combine_options do |c|
	    c.gravity "SouthEast"
	    c.fill "black"
	    c.pointsize 16
	    c.draw "text 20,10 '#{human_date}'"
	  end
	  image.write(screenshot_path)

	  # === Step 4: Convert screenshot → PDF (auto-scale)
	  pdf = Prawn::Document.new(page_layout: :portrait)
	  pdf.image screenshot_path, fit: [540, 720], position: :center
	  pdf.render_file(pdf_path)

	  # === Step 5: Log success
	  WebcrawlerLog.create!(
	    crawler_type: crawler_folder_name.upcase,
	    file_path: pdf_path.to_s.gsub(Rails.root.to_s + '/', ''),
	    status: 'success'
	  )

	  # === Step 6: Cleanup
	  [screenshot_path, pdf_path].each do |path|
	    File.delete(path) if File.exist?(path)
	  end

	rescue => e
	  WebcrawlerLog.create(
	    crawler_type: crawler_folder_name.upcase,
	    status: 'failed'
	  )
	  Rails.logger.error("❌ Screenshot failed for #{crawler_folder_name}: #{e.message}")
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
