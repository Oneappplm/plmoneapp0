class InvoicesController < ApplicationController
	before_action :set_doctor
  before_action :set_patient, except: [:index]
  before_action :set_invoice, only: [:show]

	def index
	  @invoices = @doctor.invoices.includes(:patient)
	end

	def new
		@invoice = @patient.invoices.new
		@appointments = @patient.appointments
	end

	def create
		@doctor = Doctor.find(params[:doctor_id])
		@patient = @doctor.patients.find(params[:patient_id])

		@invoice = @patient.invoices.build(invoice_params)
		@invoice.doctor = @doctor
		# @appointments = @patient.appointments

		@invoice.payment_memo = SecureRandom.hex(6)
		@invoice.status = "unpaid"

		if @invoice.save
			InvoiceMailer.send_invoice(@invoice).deliver_now
			redirect_to [@doctor, @patient, @invoice], notice: "Invoice created and sent to patient!"
		else
			render :new, status: :unprocessable_entity
		end
	end

	def show
	end

	def edit
		@appointments = @patient.appointments
	end

	def update
		@appointments = @patient.appointments
    if @invoice.update(invoice_params)
      redirect_to doctor_patient_invoice_path(@doctor, @patient, @invoice), notice: "Invoice updated!"
    else
      render :edit, status: :unprocessable_entity
    end
	end

	def confirm_invoice_payment
		invoice = Invoice.find(params[:invoice_id])

    # Enqueue payment verification job if order still pending
    if invoice.status == "unpaid"
      SolanaInvoiceJob.perform_later(invoice.id)
    end

    # Reload invoice to get updated status (optional if job is very fast)
    invoice.reload

    payment_confirmed = (invoice.status == "paid")

    respond_to do |format|
      format.json do
        render json: {
          invoice_id: invoice.id,
          status: invoice.status,
          payment_confirmed: payment_confirmed,
          message: payment_confirmed ? "Payment received! Status: Paid" : "Still waiting for confirmation. Try again later."
        }
      end
    end
	end

	def download_pdf
		invoice = @doctor.invoices.find(params[:id])
	  pdf_content = InvoicePdfGeneratorService.new(invoice).generate

	  send_data pdf_content,
	            filename: "invoice-#{invoice.invoice_number}.pdf",
	            type: "application/pdf",
	            disposition: "attachment"

	end

	private

	def set_doctor
		@doctor = current_user.doctor
	end

	def set_patient
		Rails.logger.info "DEBUG PARAMS: #{params.inspect}"
		@patient = @doctor.patients.find_by!(id: params[:patient_id])
	end

	def set_invoice
		@invoice = @doctor.invoices.find(params[:id])
	end

	def invoice_params
    params.require(:invoice).permit(:service_name, :amount, :discount, :payment_method, :status, :appointment_id, :service_name, :service_description, :amount, :discount, :tax, :payment_method, :status, :appointment_id, :date_of_service, :due_date, :clinic_name)
  end
end

