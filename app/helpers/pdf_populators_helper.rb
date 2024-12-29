module PdfPopulatorsHelper
 def pdf_sample_template
  Rails.root.join('public', 'templates', 'Careington Template.pdf')
 end
end
