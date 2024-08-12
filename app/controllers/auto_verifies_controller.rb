class AutoVerifiesController < ApplicationController
	def index
		@results = if params[:search_state].present?
			search_state	= params[:search_state].downcase
			if search_state == 'pals' && params[:license_number].present?
				Webscraper::PalsVerificationService.call(params[:license_number])
			elsif search_state == 'alaska' && params[:license_number].present?
				Webscraper::StateAlaskaService.call(params[:license_number])
			elsif search_state == 'california' && params[:license_number].present?
				Webscraper::StateCaliforniaService.call(params[:license_number])
			elsif search_state == 'oig'
				Webscraper::OigService.call(params[:last_name], params[:first_name])
			elsif	search_state == 'sam'
				Webscraper::SamService.call(params[:last_name], params[:first_name])
			elsif search_state == 'report generation' && params[:license_number].present?
				Webscraper::ReportGenerationService.call(params[:license_number])
			else
				[]
			end
		else
			[]
		end
	end

	def download_as_pdf
		webscrape = params[:webscrape] || 'crawler'
		# Generate a new PDF document
		pdf = Prawn::Document.new

		# Add the PNG image to the PDF
		png_path = Rails.root.join('public', 'webscrape', webscrape, 'screenshot.png')
		pdf.image png_path, fit: [500, 500], position: :center

		# Save the PDF to a file
		pdf_path = Rails.root.join('public', 'webscrape', webscrape, 'screenshot.pdf')
		pdf.render_file pdf_path

		# Send the PDF file as a download
		send_file pdf_path, type: 'application/pdf', disposition: 'attachment'
	end
end