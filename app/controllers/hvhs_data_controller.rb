class HvhsDataController < ApplicationController
  before_action :set_hvhs_datum, only: %i[ show edit update destroy ]

  # GET /hvhs_data or /hvhs_data.json
  def index
    @hvhs_data = if params[:search].present?
      HvhsDatum.search(params[:search]).paginate(per_page: 10, page: params[:page] || 1)
    else
      HvhsDatum.paginate(per_page: 10, page: params[:page] || 1)
    end
  end

  # GET /hvhs_data/1 or /hvhs_data/1.json
  def show
  end

  # GET /hvhs_data/new
  def new
    @hvhs_datum = HvhsDatum.new
  end

  # GET /hvhs_data/1/edit
  def edit
  end

  # POST /hvhs_data or /hvhs_data.json
  def create
    @hvhs_datum = HvhsDatum.new(hvhs_datum_params)

    respond_to do |format|
      if @hvhs_datum.save
        format.html { redirect_to hvhs_data_url, notice: "Hvhs datum was successfully created." }
        format.json { render :show, status: :created, location: @hvhs_datum }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @hvhs_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /hvhs_data/1 or /hvhs_data/1.json
  def update
    respond_to do |format|
      if @hvhs_datum.update(hvhs_datum_params)
        format.html { redirect_to hvhs_data_url, notice: "Hvhs datum was successfully updated." }
        format.json { render :show, status: :ok, location: @hvhs_datum }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @hvhs_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hvhs_data/1 or /hvhs_data/1.json
  def destroy
    @hvhs_datum.destroy

    respond_to do |format|
      format.html { redirect_to hvhs_data_url, notice: "Hvhs datum was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hvhs_datum
      @hvhs_datum = HvhsDatum.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def hvhs_datum_params
      params.require(:hvhs_datum).permit(:npi, :first_name, :middle_name, :last_name, :degree_titles, :office_address_line1, :office_address_line2, :office_city, :office_state, :office_zip_code, :phone_number, :practice_email_address, :office_mgr_email, :office_mgr_fax, :office_mgr_first_name, :office_mgr_last_name, :office_mgr_phone, :special_type, :taxonomy_code, :license_number, :license_state)
    end
end
