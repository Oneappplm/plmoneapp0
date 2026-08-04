# frozen_string_literal: true

require "prawn"
require "prawn/table"
require "tempfile"

module Ssa
  class VerificationPdfGenerator
    class PdfGenerationError < StandardError; end

    def initialize(verification)
      @verification = verification
      @provider =
        verification.provider_personal_information
      @details =
        verification.verification_details.with_indifferent_access
    end

    def call
      Tempfile.create(
        ["ssa_verification_#{@verification.id}", ".pdf"],
        binmode: true
      ) do |file|
        generate_pdf(file.path)

        file.rewind

        @verification.report_pdf.attach(
          io: File.open(file.path, "rb"),
          filename: pdf_filename,
          content_type: "application/pdf",
          identify: false
        )
      end

      @verification
    rescue StandardError => error
      Rails.logger.error(
        "[SSA PDF] " \
        "verification_id=#{@verification.id} " \
        "#{error.class}: #{error.message}"
      )

      raise PdfGenerationError,
            "Unable to generate SSA verification PDF: #{error.message}"
    end

    private

    def generate_pdf(path)
      Prawn::Document.generate(
        path,
        page_size: "LETTER",
        margin: 42,
        info: {
          Title: "SSA Death Master Verification Report",
          Author: "PLM OneApp",
          Subject: "SSA / SSN Verification"
        }
      ) do |pdf|
        render_header(pdf)
        render_status_banner(pdf)
        render_provider_information(pdf)
        render_match_information(pdf)
        render_death_master_information(pdf)
        render_disclaimer(pdf)
        render_footer(pdf)
      end
    end

    def render_header(pdf)
      pdf.text(
        "SSA Death Master Verification Report",
        size: 19,
        style: :bold,
        align: :center
      )

      pdf.move_down 5

      pdf.text(
        "Social Security Number Verification",
        size: 11,
        align: :center
      )

      pdf.move_down 18
      pdf.stroke_horizontal_rule
      pdf.move_down 18
    end

    def render_status_banner(pdf)
      pdf.bounding_box(
        [0, pdf.cursor],
        width: pdf.bounds.width,
        height: 55
      ) do
        pdf.stroke_bounds

        pdf.move_down 10

        pdf.text(
          result_heading,
          size: 17,
          style: :bold,
          align: :center
        )

        pdf.move_down 4

        pdf.text(
          result_description,
          size: 9,
          align: :center
        )
      end

      pdf.move_down 20
    end

    def render_provider_information(pdf)
      section_heading(pdf, "Provider Information")

      rows = [
        ["Provider Name", provider_full_name],
        ["SSN", masked_ssn],
        ["Date of Birth", format_date(provider_date_of_birth)],
        ["Provider Attest ID", provider_attest_id],
        ["Verification Date", format_datetime(@verification.verified_at)]
      ]

      render_table(pdf, rows)
      pdf.move_down 18
    end

    def render_match_information(pdf)
      section_heading(pdf, "Verification Match Details")

      rows = [
        ["SSN Located", boolean_label(@verification.ssn_matched)],
        ["First Name Match", match_label(@verification.first_name_matched)],
        ["Middle Name Match", match_label(@verification.middle_name_matched)],
        ["Last Name Match", match_label(@verification.last_name_matched)],
        ["Date of Birth Match", match_label(@verification.date_of_birth_matched)],
        ["Unique Records Found", @verification.matched_record_count.to_s]
      ]

      render_table(pdf, rows)
      pdf.move_down 18
    end

    def render_death_master_information(pdf)
      section_heading(pdf, "Death Master Record")

      death_master = @details[:death_master] || {}

      rows = [
        ["First Name", display_value(death_master[:first_name])],
        ["Middle Name", display_value(death_master[:middle_name])],
        ["Last Name", display_value(death_master[:last_name])],
        ["Birth Date", format_date(death_master[:birth_date])],
        ["Death Date", format_date(death_master[:death_date])],
        ["Source Date", format_datetime(death_master[:source_date])]
      ]

      render_table(pdf, rows)
      pdf.move_down 18
    end

    def render_disclaimer(pdf)
      pdf.stroke_horizontal_rule
      pdf.move_down 10

      pdf.text(
        "This report reflects the result of an automated comparison " \
        "against the available SSA Death Master database. A matched " \
        "record indicates that the SSN was located and the available " \
        "identity fields were compared. Results requiring review must " \
        "be evaluated manually before a final determination is made.",
        size: 8,
        leading: 3
      )
    end

    def render_footer(pdf)
      pdf.number_pages(
        "Page <page> of <total>",
        at: [pdf.bounds.right - 90, 0],
        width: 90,
        align: :right,
        size: 8
      )

      pdf.number_pages(
        "Verification ID: #{@verification.id}",
        at: [0, 0],
        width: 180,
        align: :left,
        size: 8
      )
    end

    def section_heading(pdf, title)
      pdf.text title, size: 12, style: :bold
      pdf.move_down 8
    end

    def render_table(pdf, rows)
      pdf.table(
        rows,
        width: pdf.bounds.width,
        column_widths: [
          180,
          pdf.bounds.width - 180
        ],
        cell_style: {
          padding: [7, 6],
          size: 9,
          borders: [:bottom]
        }
      ) do |table|
        table.column(0).font_style = :bold
      end
    end

    def result_heading
      case @verification.status
      when "matched"
        "MATCHED"
      when "not_matched"
        "NOT MATCHED"
      when "review_required"
        "REVIEW REQUIRED"
      else
        "VERIFICATION ERROR"
      end
    end

    def result_description
      case @verification.status
      when "matched"
        "A matching record was located in the SSA Death Master database."
      when "not_matched"
        "No record was located for the provider SSN."
      when "review_required"
        "A record was located, but one or more identity fields did not match."
      else
        @verification.error_message.presence ||
          "The verification could not be completed."
      end
    end

    def provider_full_name
      [
        @provider.first_name,
        provider_middle_name,
        @provider.last_name
      ].map { |value| value.to_s.strip }
       .reject(&:blank?)
       .join(" ")
       .presence || "Not available"
    end

    def provider_middle_name
      return @provider.middle_name if @provider.respond_to?(:middle_name)
      return @provider.middle_initial if @provider.respond_to?(:middle_initial)

      nil
    end

    def provider_date_of_birth
      return @provider.date_of_birth if @provider.respond_to?(:date_of_birth)
      return @provider.dob if @provider.respond_to?(:dob)
      return @provider.birth_date if @provider.respond_to?(:birth_date)

      nil
    end

    def provider_attest_id
      return "Not available" unless @provider.respond_to?(:provider_attest_id)

      @provider.provider_attest_id.presence || "Not available"
    end

    def masked_ssn
      last_four = @verification.ssn_last_four.to_s

      return "Not available" if last_four.blank?

      "***-**-#{last_four}"
    end

    def boolean_label(value)
      value ? "Yes" : "No"
    end

    def match_label(value)
      return "Not available" if value.nil?

      value ? "Matched" : "Not matched"
    end

    def display_value(value)
      value.to_s.strip.presence || "Not available"
    end

    def format_date(value)
      return "Not available" if value.blank?

      value.to_date.strftime("%m/%d/%Y")
    rescue ArgumentError, TypeError
      "Not available"
    end

    def format_datetime(value)
      return "Not available" if value.blank?

      parsed =
        if value.respond_to?(:in_time_zone)
          value.in_time_zone
        else
          Time.zone.parse(value.to_s)
        end

      parsed.strftime("%m/%d/%Y %I:%M %p")
    rescue ArgumentError, TypeError
      "Not available"
    end

    def pdf_filename
      identifier =
        @provider.respond_to?(:provider_attest_id) &&
        @provider.provider_attest_id.present? ?
          @provider.provider_attest_id :
          @provider.id

      timestamp = Time.current.strftime("%Y%m%d%H%M%S")

      "ssa_verification_#{identifier}_#{timestamp}.pdf"
    end
  end
end