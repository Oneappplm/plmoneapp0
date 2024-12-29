class PdfPopulatorsController < ApplicationController
 include PdfPopulatorsHelper
 
 def index
  @pdf_files = Dir[Rails.root.join('public', 'populated_pdf', '*.pdf')]
 end

 def populate_data
  if params.dig(:auto_populate_data).present?
    data = eval(params[:"json-data"])
    service = AutomationTool::PdfPopulatorService.new(pdf_sample_template, data)
    service.call

    redirect_to pdf_populators_path, notice: "Auto Populate data has been successfully completed."
  end
 end
end
