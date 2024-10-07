require 'zip' 
class AltEnrollmentGroupsController < ApplicationController
  include ActionController::Live  # Enables live streaming
  before_action :get_enrollment_group, only: [:locations, :documents, :enrollments, :providers]
  before_action :get_enroll_groups, only: [:enrollments]
  before_action :get_enrollment_group_providers, only: [:providers]

  def show
    if !current_user.can_access_all_groups? && !current_user.super_administrator?
    	@enrollment_group = EnrollmentGroup.where(id: current_user.enrollment_groups.pluck(:id)).where(id: params[:id] || params[:alt_enrollment_group_id]).last
			if !@enrollment_group.present?
				redirect_back(fallback_location: root_path, alert: "You don't have access to the group.")
			end
		else
			@enrollment_group = EnrollmentGroup.find(params[:id] || params[:alt_enrollment_group_id])
		end
  end
  
  def download_all_as_zip
    enrollment_groups = EnrollmentGroup.all
    temp_zip = Tempfile.new("enrollment_groups.zip")
  
    begin
      Zip::OutputStream.open(temp_zip.path) do |zip|
        enrollment_groups.each do |group|
          csv_data = CSV.generate(headers: true) do |csv|
            csv << ["Group Name", "Taxonomy Code", "State", "Number of Location", "Number of Providers"]
            csv << [
              group.group_name,
              group.group_code,
              group.state,
              group.dco_count_display,
              group.providers.count
            ]
          end
  
          zip.put_next_entry("#{group.group_name}.csv")
          zip.print csv_data
        end
      end
  
      logger.info "ZIP file created at: #{temp_zip.path}" # Log the location of the temp file
  
      send_file temp_zip.path, type: 'application/zip', disposition: 'attachment', filename: "enrollment_groups.zip"
    rescue StandardError => e
      logger.error "Error while downloading: #{e.message}" # Log any errors
      flash[:error] = "There was an error downloading the file. Please try again."
      redirect_to some_path # Redirect to an appropriate path
    ensure
      temp_zip.close
      temp_zip.unlink
    end
  end  

  def documents; end

  def enrollments; end

  def providers; end

  private

  def get_enrollment_group
    @enrollment_group = EnrollmentGroup.find(params[:id] || params[:alt_enrollment_group_id])
  end

  def get_enroll_groups
    # get's enroll group to get the enroll_group.details where most important information are.
    @enroll_groups = EnrollGroup.where(group_id: @enrollment_group.id)
  end

  def get_enrollment_group_providers
    @providers = @enrollment_group.providers
    @providers = @providers.paginate(per_page: 50, page: params[:page] || 1)
  end
end