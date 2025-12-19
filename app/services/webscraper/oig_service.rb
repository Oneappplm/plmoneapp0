# frozen_string_literal: true

class Webscraper::OigService < WebscraperService
  attr_reader :last_name, :first_name, :middle_name

  LAST_FIELD_ID   = 'ctl00_cpExclusions_txtSPLastName'
  FIRST_FIELD_ID  = 'ctl00_cpExclusions_txtSPFirstName'
  SEARCH_BTN_ID   = 'ctl00_cpExclusions_ibSearchSP'
  RESULTS_CLASS   = 'leie_search_results'
  BACK_TO_SEARCH  = 'ctl00_cpExclusions_lbBackToSearch'

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

    found = false

    fast_attempts.each do |a|
      next if a[:last].blank?

      # ✅ if we’re on a details page from a previous run, go back first
      back_to_search_if_present

      fill_fields(a[:last], a[:first])
      crawler.find_element(:id, SEARCH_BTN_ID).click
      sleep(0.8)

      # If Verify exists -> click it and finish
      if click_verify_if_present
        sleep(0.8)
        safe_save_screenshot # ✅ result screenshot
        found = true
        break
      end

      # No results -> continue (still on search page)
    end

    safe_save_screenshot unless found # ✅ no-result screenshot (final state)
  ensure
    crawler.quit rescue nil
  end

  private

  def fast_attempts
    ln = last_name
    fn = first_name
    mn = middle_name

    attempts = []
    attempts << { last: ln, first: fn } if ln.present?
    attempts << { last: fn, first: ln } if ln.present? && fn.present?
    attempts << { last: mn, first: fn } if mn.present? && fn.present?
    attempts << { last: mn, first: ln } if mn.present? && ln.present?
    attempts << { last: ln, first: '' } if ln.present?
    attempts.uniq
  end

  def back_to_search_if_present
    btn = crawler.find_element(:id, BACK_TO_SEARCH) rescue nil
    return unless btn.present?

    btn.click
    sleep(0.6)
  end

  def fill_fields(last_value, first_value)
    last_el  = crawler.find_element(:id, LAST_FIELD_ID)
    first_el = crawler.find_element(:id, FIRST_FIELD_ID)

    quick_clear(last_el)
    quick_clear(first_el)

    last_el.send_keys(last_value.to_s.strip)
    first_el.send_keys(first_value.to_s.strip) if first_value.to_s.strip.present?
  end

  def click_verify_if_present
    table = crawler.find_element(:class, RESULTS_CLASS) rescue nil
    return false unless table.present?

    link = table.find_element(xpath: ".//a[contains(., 'Verify')]") rescue nil
    return false unless link.present?

    link.click
    true
  end

  def quick_clear(el)
    el.clear
  rescue StandardError
    el.send_keys([:control, 'a'])
    el.send_keys(:backspace)
  end

  def safe_save_screenshot
    save_screenshot
  rescue => e
    Rails.logger.error("❌ OIG screenshot failed: #{e.class} - #{e.message}")
    nil
  end
end
