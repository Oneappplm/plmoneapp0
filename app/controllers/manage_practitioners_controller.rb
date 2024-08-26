class ManagePractitionersController < ApplicationController
  before_action :set_practitioner, only: [:show, :edit, :update, :destroy]

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
      redirect_to manage_practitioner_path, notice: 'Practitioner was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
    respond_to do |format|
      format.html
      format.json { render json: @practitioner }
    end
  end

  def update
    if @practitioner.update(practitioner_params)
      redirect_to manage_practitioner_path, notice: 'Practitioner was successfully updated.'
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
    # Ensure you have strong parameters to permit required fields
    practitioner_id = params[:practitioner_id]
    image_classification = params[:image_classification]
    sub_section = params[:sub_section]
    description = params[:description]
  
    # Check if file is present
    if params[:file].present?
      uploaded_file = params[:file]
      
      # Create a new record in the database
      document = ClientUploadedDocument.new(
        practitioner_id: practitioner_id,
        image_classification: image_classification,
        sub_section: sub_section,
        description: description
      )
      
      # Assign and save the uploaded file
      document.file_upload = uploaded_file
      if document.save
        flash[:success] = "File uploaded and record saved successfully!"
      else
        flash[:error] = "Error saving record."
      end
    else
      flash[:error] = "Please select a file to upload."
    end
  
    redirect_to manage_clients_path
  end

  def load_files
    practitioner_id = params[:practitioner_id]
    @documents = ClientUploadedDocument.where(practitioner_id: practitioner_id)

    respond_to do |format|
      format.html { render partial: 'uploaded_documents_table', locals: { documents: @documents } }
    end
  end
  
  def delete_files
    if params[:doc_id].present?
      document = ClientUploadedDocument.find(params[:doc_id])
      file_path = document.file_upload.path
  
      if File.exist?(file_path)
        File.delete(file_path)
        document.destroy
        flash[:success] = "File deleted successfully!"
      else
        flash[:error] = "File not found."
      end
    else
      flash[:error] = "No file selected for deletion."
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

  private

  def set_practitioner
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
      :county
    )
  end
end
