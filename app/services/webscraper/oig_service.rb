# frozen_string_literal: true

class Webscraper::OigService < WebscraperService
  attr_reader :last_name, :first_name, :middle_name

  LAST_FIELD_ID      = 'ctl00_cpExclusions_txtSPLastName'
  FIRST_FIELD_ID     = 'ctl00_cpExclusions_txtSPFirstName'
  SEARCH_BTN_ID      = 'ctl00_cpExclusions_ibSearchSP'
  RESULTS_CLASS      = 'leie_search_results'
  BACK_TO_SEARCH_ID  = 'ctl00_cpExclusions_lbBackToSearch'

  def initialize(last_name = 'emmet', first_name = '', middle_name = '')
    @last_name   = last_name.to_s.strip
    @first_name  = first_name.to_s.strip
    @middle_name = middle_name.to_s.strip
    @crawler_folder = 'oig'
  end

  def call
    crawl
  end

  def crawl!
    crawler.get('https://exclusions.oig.hhs.gov/default.aspx')

    attempts.each do |a|
      next if a[:last].blank?

      back_to_search_if_present_fast

      last_el  = crawler.find_element(:id, LAST_FIELD_ID)
      first_el = crawler.find_element(:id, FIRST_FIELD_ID)

      safe_clear(last_el)
      safe_clear(first_el)

      last_el.send_keys(a[:last]) if a[:last].present?
      first_el.send_keys(a[:first]) if a[:first].present?

      crawler.find_element(:id, SEARCH_BTN_ID).click

      # ✅ Fast bounded wait (exits ASAP, max ~1.8s)
      wait_for_results_state!(timeout: 1.8)

      table = crawler.find_element(:class, RESULTS_CLASS) rescue nil
      next unless table.present?

      link = table.find_element(xpath: ".//a[contains(., 'Verify')]") rescue nil
      if link.present?
        link.click
        # ✅ short wait for verify/details page
        wait_for_back_button!(timeout: 1.5)
        break
      end
      # no verify => no results, continue attempts
    end

    save_screenshot
    crawler.quit
  end

  private

  def attempts
    ln = last_name.presence
    fn = first_name.presence
    mn = middle_name.presence

    list = []
    list << { last: ln, first: fn } if ln
    list << { last: fn, first: ln } if ln && fn

    if mn
      list << { last: mn, first: fn } if fn
      list << { last: mn, first: ln } if ln
      list << { last: ln, first: mn } if ln
      list << { last: fn, first: mn } if fn
    end

    [ln, fn, mn].compact.uniq.each { |t| list << { last: t, first: '' } }

    list.uniq
  end

  def safe_clear(el)
    el.clear
  rescue StandardError
    el.send_keys([:control, 'a'])
    el.send_keys(:backspace)
  end

  # ✅ Only click back when it exists, and don’t sleep unless clicked
  def back_to_search_if_present_fast
    btn = crawler.find_elements(:id, BACK_TO_SEARCH_ID).first
    return unless btn

    btn.click
    wait_for_search_form!(timeout: 2.0)
  rescue StandardError
    # ignore; continue
  end

  # ✅ Wait for search form fields (after Back)
  def wait_for_search_form!(timeout:)
    Selenium::WebDriver::Wait.new(timeout: timeout).until do
      crawler.find_elements(:id, LAST_FIELD_ID).any? &&
        crawler.find_elements(:id, FIRST_FIELD_ID).any? &&
        crawler.find_elements(:id, SEARCH_BTN_ID).any?
    end
  rescue Selenium::WebDriver::Error::TimeoutError
    false
  end

  # ✅ Wait until results area exists (table rendered) OR verify exists
  def wait_for_results_state!(timeout:)
    Selenium::WebDriver::Wait.new(timeout: timeout).until do
      table = crawler.find_elements(:class, RESULTS_CLASS).first
      next false unless table

      # either verify link OR table has text (no-results state still renders text)
      verify = table.find_elements(xpath: ".//a[contains(., 'Verify')]")
      verify.any? || table.text.to_s.strip.present?
    end
  rescue Selenium::WebDriver::Error::TimeoutError
    false
  end

  def wait_for_back_button!(timeout:)
    Selenium::WebDriver::Wait.new(timeout: timeout).until do
      crawler.find_elements(:id, BACK_TO_SEARCH_ID).any?
    end
  rescue Selenium::WebDriver::Error::TimeoutError
    false
  end
end
