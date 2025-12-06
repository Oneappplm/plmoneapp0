module Webscraper
	@license_number = license_number
	@crawler_folder = 'webcrawler'
end


# Provide a Selenium driver wrapper. Replace with your project's crawler initializer.
	def crawler
		@crawler ||= begin
	# Example: ::Selenium::WebDriver.for :chrome, options: chrome_options
	# Use project's helper here. This is a placeholder that should exist in your app.
	raise NotImplementedError, "Implement crawler initialization in your app"
	end
end


def save_screenshot
# Implement screenshot saving like your existing save_screenshot method
# Return path or webcrawler_log object as your app expects
"screenshot-placeholder"
end


private


def fast_wait
	Selenium::WebDriver::Wait.new(timeout: 4)
end


def slow_wait
	Selenium::WebDriver::Wait.new(timeout: 15)
end
end
end