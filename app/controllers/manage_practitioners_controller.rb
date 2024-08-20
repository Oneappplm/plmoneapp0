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

   def upload_documents
    practitioner_id = params[:practitioner_id]
    if params[:file].present?
      upload_path = Rails.root.join('public', 'uploads', practitioner_id.to_s)
      FileUtils.mkdir_p(upload_path) unless File.directory?(upload_path)

      uploaded_file = params[:file]
      file_path = Rails.root.join(upload_path, uploaded_file.original_filename)

      # Debugging output
      puts "Saving file to: #{file_path}"

      File.open(file_path, 'wb') do |file|
        file.write(uploaded_file.read)
      end

      flash[:success] = "File uploaded successfully!"
    else
      flash[:error] = "Please select a file to upload."
    end

    redirect_to manage_clients_path
  end

  def delete_files
    if params[:files].present?
      practitioner_id = params[:practitioner_id]
      params[:files].each do |filename|
        file_path = Rails.root.join('public', 'uploads', practitioner_id.to_s, filename)
        File.delete(file_path) if File.exist?(file_path)
      end
      flash[:success] = "Selected files removed successfully!"
    else
      flash[:error] = "No files selected for removal."
    end
    redirect_to manage_clients_path
  end

  def show_uploaded_files
    practitioner_id = params[:practitioner_id]
    upload_path = Rails.root.join('public', 'uploads', practitioner_id.to_s)
    
    if Dir.exist?(upload_path)
      files = Dir.glob("#{upload_path}/*").map do |file_path|
        {
          name: File.basename(file_path),
          mtime: File.mtime(file_path).strftime('%Y-%m-%d %H:%M:%S')
        }
      end
      render json: { files: files }
    else
      render json: { files: [] }
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
