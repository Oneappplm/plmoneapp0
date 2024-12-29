module PdfPopulatorsHelper
 def pdf_sample_template pdf_form = "careington"
  if pdf_form == "emblemhealth"
   Rails.root.join('public', 'templates', 'dental-provider-application-template.pdf')
  elsif pdf_form == "paper"
   Rails.root.join('public', 'templates', 'Paper Provider Application Template.pdf')
  else
   Rails.root.join('public', 'templates', 'Careington Template.pdf')
  end
 end
end
