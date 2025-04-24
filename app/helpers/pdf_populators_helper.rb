module PdfPopulatorsHelper
 def pdf_sample_template pdf_form = "careington"
  if pdf_form == "emblemhealth"
   Rails.root.join('public', 'templates', 'dental-provider-application-template.pdf')
  elsif pdf_form == "paper"
   Rails.root.join('public', 'templates', 'Paper Provider Application Template.pdf')
  elsif pdf_form == "guardian"
   Rails.root.join('public', 'templates', 'Guardian-PPO-New.pdf')
  elsif pdf_form == "credentialing"
   Rails.root.join('public', 'templates', 'co-credentialing-form.pdf')
  elsif pdf_form == "illinois"
    Rails.root.join('public', 'templates', 'Illinois_cred_application.pdf')
  else
   Rails.root.join('public', 'templates', 'Careington Template.pdf')
  end
 end
end
