class SystemsController < ApplicationController

	def index;end

	def edit;end

	def new;end

	def show;end

	def sub_features
  end

  def securables;end

  def acl
    if params[:page].present?
      render "systems/acl_pages/#{params[:page]}"
    end
  end

  def data_lookup
    if params[:page].present?
      render "systems/data_lookup_pages/#{params[:page]}"
    end
  end

  def data_import
    if params[:page].present?
      render "systems/data_import_pages/#{params[:page]}"
    end
  end

end
