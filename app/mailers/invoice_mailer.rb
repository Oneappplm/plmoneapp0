class InvoiceMailer < ApplicationMailer
	default from: "no-reply@oneapp.com"

	def send_invoice(invoice)
		@invoice = invoice
		@doctor = invoice.doctor
		@patient = invoice.patient

		mail(
			to: @patient.email_address,
			subject: "New Invoice from Dr. #{@doctor.full_name}"
		)
	end
end
