class SpecialtyDetailsController < ApplicationController
  before_action :set_specialty_detail, only: %i[show edit update destroy]

  def index
    @specialty_details = SpecialtyDetail.all
  end

  def show
  end

  def new
    @specialty_detail = SpecialtyDetail.new
  end

  def create
    @specialty_detail = SpecialtyDetail.new(specialty_detail_params)
    if @specialty_detail.save
      redirect_to provider_engage_path(page: 'specialties'), notice: "Specialty Detail was successfully created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @specialty_detail.update(specialty_detail_params)
      redirect_to @specialty_detail, notice: "Specialty Detail was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @specialty_detail.destroy
    redirect_to specialty_details_url, notice: "Specialty Detail was successfully deleted."
  end

  private

  def set_specialty_detail
    @specialty_detail = SpecialtyDetail.find(params[:id])
  end

def specialty_detail_params
  params.require(:specialty_detail).permit(:ranking, :specialty, :certified, :certifying_board, :address_line_1, :address_line_2, :city, :state, :zip, :board_certificate, :telephone, :initial_date, :expiration_date, :ppo_directory, :pos_directory, :provider_directory, :hmo_directory, :board_certified, :certified_eligible, :failed_exam,
  :certification_expiry, :failed_exam_date, :failed_exam_certifying_board, :failed_exam_reason, :target_population_privileges, :populations_employment_type, :populations_served, :specialty_student_intern, :populations_infos, :populations_served_text
  )
end
end
