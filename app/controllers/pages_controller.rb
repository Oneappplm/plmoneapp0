class PagesController < ApplicationController
	before_action :set_global_search, only: [:virtual_review_committee]

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

	def virtual_review_committee
		@vrcs = if @global_search_text.present?
			VirtualReviewCommittee.search(@global_search_text)
		else
			VirtualReviewCommittee.all
		end

		if params[:'vrc-progress-status'].present? && params[:'vrc-progress-status'] != 'all'
			@vrcs = @vrcs.send(params[:'vrc-progress-status'])
		end

		@vrcs = @vrcs.paginate(page: params[:page], per_page: 5)
	end

	protected

	def set_global_search
		global_search_data = []
		vrc_columns = VirtualReviewCommittee.column_names.dup.push('first_name', 'last_name')

		vrc_columns.each do |search_key|
			if params[search_key.to_sym].present?
				global_search_data << params[search_key.to_sym]
			end
		end
		@global_search_text = global_search_data.join(',')
	end
end