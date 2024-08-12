class ManagePractitionersController < ApplicationController
  before_action :set_practitioners, only: [:show, :edit, :update, :destroy]

  def index
    if params[:display_all]
      @practitioners = Practitioner.all
    else
      @practitioners = Practitioner.paginate(page: params[:page])
    end
  end

  def new
    @practitioner = Practitioner.new
  end

  def create
    @practitioner = Practitioner.new(practitioner_params)

    if @practitioner.save
      redirect_to manage_practitioners_path, notice: 'Practitioner was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @practitioner.update(practitioner_params)
      redirect_to manage_practitioners_path, notice: 'Practitioner was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @practitioner.destroy
    redirect_to manage_practitioners_path, notice: 'Practitioner was successfully deleted.'
  end

  def manage_practitioners_data
    if params[:display_all]
      @practitioners = Practitioner.all
    else
      @practitioners = Practitioner.paginate(page: params[:page])
    end
  end

  def save_not_applicable
    @practitioner = Practitioner.find(params[:practitioner_id])
    @practitioner.update(not_applicable_explain: params[:not_applicable_explain])

    if @practitioner.save
      flash[:success] = "Form saved successfully."
    else
      flash[:error] = "There was an error saving the form."
    end
    redirect_to verification_platform_index_path(page: 'app_tracking', practitioner: @practitioner)
  end

  private

  def set_practitioners
    @practitioner = Practitioner.find(params[:id])
  end

  def practitioner_params
    params.require(:practitioner).permit(
      :first_name, :middle_name, :last_name, :suffix, :gender, :date_of_birth, 
      :social_security_number, :contact_method, :phone_number, :fax_number, 
      :email_address, :address, :suit_or_apt, :additional_address, :city, 
      :country, :state_or_province, :zipcode, :practitioner_type, 
      :credentials_committee_date, :client_batch_name, 
      :client_batch_id, :market, :status, :application_method, :availability, 
      :county,
      :not_applicable_explain
    )
  end
end
