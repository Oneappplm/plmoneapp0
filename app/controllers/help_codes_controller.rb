class HelpCodesController < ApplicationController
  include HelpCodesHelper
  before_action :set_help_code, only: %i[ show edit update destroy ]

  # GET /help_codes or /help_codes.json
  def index 
    @help_codes = if table_view?
      HelpCode.all.paginate(per_page: 10, page: params[:page] || 1)

      if params[:search].present?
        HelpCode.search_by_category_and_code(params[:search]).paginate(page: params[:page], per_page: params[:per_page] || 15)
      else
        HelpCode.paginate(page: params[:page], per_page: params[:per_page] || 15)
      end

    else
      HelpCode.all.group_by(&:category).sort_by do |category, _|
        HelpCode.categories.keys.index(category)
      end
    end


  end

  # GET /help_codes/1 or /help_codes/1.json
  def show
  end

  # GET /help_codes/new
  def new
    @help_code = HelpCode.new
  end

  # GET /help_codes/1/edit
  def edit
  end

  # POST /help_codes or /help_codes.json
  def create
    @help_code = HelpCode.new(help_code_params)

    respond_to do |format|
      if @help_code.save
        format.html { redirect_to help_codes_url, notice: "Help code was successfully created." }
        format.json { render :show, status: :created, location: @help_code }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @help_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /help_codes/1 or /help_codes/1.json
  def update
    respond_to do |format|
      if @help_code.update(help_code_params)
        format.html { redirect_to help_codes_url, notice: "Help code was successfully updated." }
        format.json { render :show, status: :ok, location: @help_code }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @help_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /help_codes/1 or /help_codes/1.json
  def destroy
    @help_code.destroy

    respond_to do |format|
      format.html { redirect_to help_codes_url, notice: "Help code was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_help_code
      @help_code = HelpCode.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def help_code_params
      params.require(:help_code).permit(:category, :code, :description)
    end  
end
