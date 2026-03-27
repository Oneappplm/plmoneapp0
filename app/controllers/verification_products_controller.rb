class VerificationProductsController < ApplicationController
  def index
    @verification_products = VerificationProduct.order(created_at: :desc).paginate(per_page: 10, page: params[:page] || 1)
  end

  def new
    @verification_product = VerificationProduct.new
  end

  def create
    @verification_product = VerificationProduct.new(verification_product_params)
    if @verification_product.save
      redirect_to verification_products_path
    else
      render :new
    end
  end

  private

  def verification_product_params
    params.require(:verification_product).permit(:name, :description, :price)
  end
end

