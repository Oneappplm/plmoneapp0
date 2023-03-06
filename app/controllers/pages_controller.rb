class PagesController < ApplicationController
	def virtual_review_committee
		if params[:vrc].present? && params[:vrc] == 'work-tickler'
			render 'work_tickler'
		elsif params[:vrc].present? && params[:vrc] == 'documents'
			render 'documents'
		end
	end

	def provider_source
		if params[:page].present?
			render "pages/provider_source/#{params[:page]}"
		end
	end

	def plm_sales_tool
		render layout: 'plm_sales_tool'
	end
end