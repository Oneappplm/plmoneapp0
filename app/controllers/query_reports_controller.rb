class QueryReportsController < ApplicationController

  def index
    if params[:page].present?
      render params[:page]
    end
  end

  def staff_directory
  end

  def provider_directory
  end

  def privilege_reporting_tool
  end

  def meeting_report_by_practitioner
  end

  def cme_practitioner_profile
  end

  def customer_reporting_service
  end
end
