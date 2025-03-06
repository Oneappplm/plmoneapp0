class ProfessionalOrganizationsController < ApplicationController
  before_action :set_professional_organization, only: [:show, :edit, :update, :destroy]

  def index
    @professional_organizations = ProfessionalOrganization.all
  end

  def new
    @professional_organization = ProfessionalOrganization.new
  end

  def create
    @professional_organization = ProfessionalOrganization.new(professional_organization_params)

    if @professional_organization.save
      redirect_to "/provider-engage?page=prof_organization", notice: 'Record successfully saved.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @professional_organization.update(professional_organization_params)
      redirect_to professional_organizations_path, notice: 'Record updated successfully.'
    else
      render :edit
    end
  end

  def destroy
    @professional_organization.destroy
    redirect_to professional_organizations_path, notice: 'Record deleted successfully.'
  end

  private

  def set_professional_organization
    @professional_organization = ProfessionalOrganization.find(params[:id])
  end

  def professional_organization_params
    params.require(:professional_organization).permit(:prof_organization_name, :prof_org_effected_date, :prof_org_termination_date, :prof_org_until_current)
  end
end
