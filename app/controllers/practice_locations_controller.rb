class PracticeLocationsController < ApplicationController
  before_action :set_practice_location, only: [:destroy, :update]

  def create
    # render json: params and return
    @practice_location = PracticeLocation.new(practice_location_params)
    if @practice_location.save
      redirect_to request.referrer, notice: 'New location successfully added.'
    end
  end

  def update
    if @practice_location.update(practice_location_params)
      redirect_to request.referrer, notice: 'Updated location successfully.'
    end
  end

  def destroy
    if @practice_location.destroy
      if request.xhr?
        flash[:notice] = 'Location successfully removed.'
        render json: { success: true }
      else
        redirect_to request.referrer, notice: 'Location successfully removed.'
      end
    end
  end

  protected
  def set_practice_location
    @practice_location = PracticeLocation.find(params[:id])
  end

  def practice_location_params
    params.require(:practice_location).permit(:location, :legal_name, :address1, :address2,
                                              :city, :state_id, :zip_code, :phone_number, :fax_number,
                                              :email, :group_tax_number, :group_npi_number, :have_group_tax_number,
                                              :group_npi_number_effective_date, :languages_speak, :languages_write,
                                              :contact_first_name, :contact_middle_name, :contact_last_name,
                                              :contact_suffix, :contact_title, :contact_phone_number, :contact_ext,
                                              :contact_fax_number, :contact_email, :monday_time_start, :monday_time_end,
                                              :monday_split_day, :monday_closed, :tuesday_time_start, :tuesday_time_end,
                                              :tuesday_split_day, :tuesday_closed, :wednesday_time_start, :wednesday_time_end,
                                              :wednesday_split_day, :wednesday_closed, :thursday_time_start, :thursday_time_end,
                                              :thursday_split_day, :thursday_closed, :friday_time_start, :friday_time_end,
                                              :friday_split_day, :friday_closed, :saturday_time_start, :saturday_time_end,
                                              :saturday_split_day, :saturday_closed, :sunday_time_start, :sunday_time_end,
                                              :sunday_split_day, :sunday_closed, :comment, :telephone_coverage, :telephone_coverage_type,
                                              :telephone_number_after_hours, :telephone_number_ext, :pa_practice_status,
                                              :pa_by_health_plan, :pa_limitations, :pa_gender_limitations, :pa_minimum_age, :pa_maximum_age,
                                              :pa_min_max_not_applicable, :pa_other_limitations, :ada_accessibility, :ada_wrp,
                                              :disabled_other_services, :disabled_other_services_wrp, :public_transportation,
                                              :public_transportation_wrp, :laboratory_services, :laboratory_services_wrp, :clia_waiver,
                                              :clia_waiver_wrp, :clia_waiver_expiration_date, :clia_certificate, :clia_certificate_wrp,
                                              :clia_certificate_expiration_date, :radiology_services, :radiology_services_xray,
                                              :radiology_services_fda, :anesthesia_administered, :additional_procedures
                                             )

  end

end
