class AppointmentsController < ApplicationController
  before_action :set_doctor
  before_action :set_patient, if: -> { params[:patient_id].present? }

  def index
    @appointments = @doctor.appointments.includes(:patient)
  end

  def new
    @appointment = @patient.appointments.new
  end

  def create
    @appointment = @patient.appointments.new(appointment_params)
    @appointment.doctor = @doctor
    if @appointment.save
      redirect_to doctor_patient_path(@doctor, @patient), notice: "Appointment scheduled successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @appointment = @doctor.appointments.find(params[:id])
  end

  private

  def set_patient
    @patient = @doctor.patients.find(params[:patient_id])
  end

  def set_doctor
    @doctor = current_user.doctor
  end

  def appointment_params
    params.require(:appointment).permit(:appointment_date, :reason, :status)
  end
end
