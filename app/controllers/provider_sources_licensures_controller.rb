class ProviderSourcesLicensuresController < ApplicationController
    def index
      @licensures = ProviderSourceLicensure.all
    end
  
    def new
      @licensure = ProviderSourceLicensure.new
    end 
    
    def create
      @licensure = ProviderSourceLicensure.new(licensure_params)
  
      if @licensure.save
        flash[:notice] = "Licensure record created successfully!"
        redirect_to "/provider-engage?page=licensure"
      else
        flash[:alert] = "Failed to create licensure record."
        render :new
      end
    end
  
    private
   
    def licensure_params
      params.require(:provider_source_licensure).permit(
        :licensure_state, :license_type, :license_number, :license_status,
        :licensure_issue_date, :licensure_expiration_date, :licensure_not_expire,
        :licensure_practice_state, :licensure_primary_license, :licensure_require_supervision,
        :licensure_sponsor_fname, :licensure_sponsor_mname, :licensure_sponsor_lname,
        :licensure_sponsor_suffix, :licensure_sponsor_degree
      ).transform_values { |v| v == "no" ? false : v }
    end     
end
