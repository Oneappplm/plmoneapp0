class ReferencesController < ApplicationController
  before_action :set_reference, only: %i[show edit update destroy]

  def index
    @references = Reference.all
  end

  def show; end

  def new
    @reference = Reference.new
  end

  def create
    @reference = Reference.new(professional_reference_params)
    if @reference.save
      redirect_to provider_engage_path(page: 'prof_references'), notice: 'Professional reference was successfully created.'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @reference.update(professional_reference_params)
      redirect_to @reference, notice: 'Professional reference was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @reference.destroy
    redirect_to references_url, notice: 'Professional reference was successfully deleted.'
  end

  private

  def set_professional_reference
    @reference = Reference.find(params[:id])
  end

  def professional_reference_params
    params.require(:reference).permit(:first_name, :middle_name, :last_name, :suffix, :degree, :specialty, :contact_method, :address_line1, :address_line2, :city, :state, :zipcode, :telephone_number, :ext, :fax, :does_not_have_fax, :mobile_number, :email_address, :association_start_date, :association_end_date, :association_until_present, :relationship)
  end
end
