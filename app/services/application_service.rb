# frozen_string_literal: true

require 'selenium-webdriver'

class ApplicationService
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  attr_reader :result, :errors

  def self.call(*args, &block)
    new(*args, &block).call
  end

  def success? = errors.blank?
  def errors? = errors.present?
  def display_error = errors
  def display_result = result

  def send_result data
    @result = data || []

    self
  end

  def send_error data
    @errors = data || []

    self
  end
end
