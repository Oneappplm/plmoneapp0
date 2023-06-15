class OigsController < ApplicationController
	def download_as_pdf
		# Generate a new PDF document
		pdf = Prawn::Document.new

		# Add the PNG image to the PDF
		png_path = Rails.root.join('public', 'webscraper', 'oig', 'screenshot.png')
		pdf.image png_path, fit: [500, 500], position: :center

		# Save the PDF to a file
		pdf_path = Rails.root.join('public', 'webscraper', 'oig', 'screenshot.pdf')
		pdf.render_file pdf_path

		# Send the PDF file as a download
		send_file pdf_path, type: 'application/pdf', disposition: 'attachment'
	end
end