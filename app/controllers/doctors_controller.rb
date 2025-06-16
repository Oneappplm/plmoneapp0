class DoctorsController < ApplicationController

  def index
    # @doctors = Doctor.all
    if current_user&.user_role == "doctor"
      @doctor = current_user.doctor
    end
  end

  def new
    @doctor = Doctor.new
  end

  def create
    @doctor = Doctor.new(doctor_params)
    @doctor.user = current_user
    if @doctor.save
      redirect_to @doctor, notice: "Doctor account created successfully."
    else
      render :new
    end
  end

  def show
    @doctor = Doctor.find(params[:id])
  end

  private

  def doctor_params
    params.require(:doctor).permit(:first_name, :last_name, :specialty, :license_number, :phone, :profile_picture,
      :clinic_name, :clinic_address, :location)
  end
end
