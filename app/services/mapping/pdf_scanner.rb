class Mapping::PdfScanner < ApplicationService
	attr_reader :filepath, :python_script

	def initialize filepath = nil
	 @filepath = filepath || Rails.root.join('lib', 'data', 'pdfs', "guardian-ppo-abboushi.pdf")
	 @python_script = Rails.root.join('lib', 'python', 'pdf-reader', 'pdf-reader.py')
	end

	def call
		return unless filepath.present?

		JSON.parse(`python3 #{python_script} #{filepath}`)
	end
end
