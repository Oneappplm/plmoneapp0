class InvoicePdfGeneratorService
  def initialize(invoice)
    @invoice = invoice
  end

  def generate
    Prawn::Document.new(page_size: 'A4', margin: 40) do |pdf|
      pdf.font_families.update("Helvetica" => {
        normal: "Helvetica",
        bold: "Helvetica-Bold"
      })

      header_height = 30
      header_y = pdf.cursor

      # Header
      pdf.fill_color "3366cc"
      pdf.fill_rectangle [0, header_y], pdf.bounds.width, header_height

      pdf.fill_color "ffffff"

      pdf.bounding_box([0, header_y], width: pdf.bounds.width, height: header_height) do
			  pdf.fill_color "ffffff"
			  pdf.text_box "Invoice ##{@invoice.invoice_number}", size: 14, style: :bold, at: [10, header_height - 8]

			  status_color = @invoice.paid? ? "00cc66" : "888888"
			  pdf.fill_color status_color
			  pdf.text_box @invoice.status.titleize,
			               size: 12,
			               at: [pdf.bounds.width - 100, header_height - 8],
			               width: 90,
			               align: :right
			end


      # Patient & Doctor Info
      pdf.fill_color "000000"
      pdf.move_down 10
      pdf.text "Patient: #{@invoice.patient.full_name}", size: 14
      pdf.text "Doctor: #{@invoice.doctor.full_name}", size: 14
      pdf.text "Clinic: #{@invoice.clinic_name}" if @invoice.clinic_name.present?
      pdf.move_down 10

      pdf.text "Appointment: #{@invoice.appointment&.appointment_date&.strftime("%B %d, %Y at %I:%M %p") || 'N/A'}", size: 11
      pdf.text "Date of Service: #{@invoice.date_of_service&.strftime("%B %d, %Y") || 'N/A'}", size: 11
      pdf.text "Due Date: #{@invoice.due_date&.strftime("%B %d, %Y") || 'N/A'}", size: 11
      pdf.move_down 20

      # Service Details
      pdf.text "Service Details", size: 14, style: :bold, color: "555555"
      pdf.move_down 5
      pdf.text "Service: #{@invoice.service_name}", size: 12
      pdf.text "Description: #{@invoice.service_description}", size: 12 if @invoice.service_description.present?
      pdf.move_down 20

      # Charges
      pdf.text "Charges", size: 14, style: :bold, color: "555555"
      pdf.move_down 5
      data = [
        ["Amount", "$#{@invoice.amount}"],
        ["Discount", "$#{@invoice.discount}"],
        ["Tax", "$#{@invoice.tax || '0'}"],
        ["Total", "$#{@invoice.total || (@invoice.amount - @invoice.discount)}"],
        ["Payment Method", "#{@invoice.payment_method || 'Not Selected'}"],
        ["Payment Status", "#{@invoice.status.titleize}"]
      ]
      pdf.table(data, width: pdf.bounds.width, cell_style: { borders: [], padding: [4, 8, 4, 0] }) do
        row(3).font_style = :bold
      end
      pdf.move_down 20

      # Payment Confirmation
      if @invoice.paid?
        pdf.fill_color "00aa55"
        pdf.text "Payment received!", size: 12, style: :bold
        if @invoice.solana_signature.present?
          pdf.fill_color "000000"
          pdf.text "Solana Tx Signature:", size: 10
          pdf.text @invoice.solana_signature, size: 9, inline_format: true
        end
      else
        pdf.fill_color "ff3333"
        pdf.text "Payment pending", size: 12, style: :bold
      end
    end.render
  end
end
