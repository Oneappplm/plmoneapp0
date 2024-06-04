class DataMappingsController < ApplicationController
 def index
		filename = params.dig(:filename) || 'guardian-ppo-abboushi.pdf'

		@data = Mapping::PdfScanner.call Rails.root.join('lib', 'data', 'pdfs', filename)
	end
end
