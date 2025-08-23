class PatientsController < ApplicationController
  before_action :set_doctor

  def index
    @patients = @doctor.patients
  end

  def new
    @patient = @doctor.patients.new
  end

  def create
    @patient = @doctor.patients.new(patient_params)
    @doctor.user = current_user
    if @patient.save
      redirect_to doctor_patients_path(@doctor), notice: "Patient created successfully."
    else
      puts @patient.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @patient = @doctor.patients.find(params[:id])
  end

  private 

  def set_doctor
    @doctor = current_user.doctor
  end

  def patient_params
    params.require(:patient).permit(:first_name, :last_name, :dob, :medical_history, :emergency_contact, :status, :gender, :email_address, :phone_number, :insurance_information, :address, :next_appointment, :last_visit_date, :active, :current_medications, :allergies)
  end
end
