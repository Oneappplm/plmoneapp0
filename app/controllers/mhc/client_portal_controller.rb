class Mhc::ClientPortalController < ApplicationController
  before_action :redirect_to_auto_verify, only: [:index]
  before_action :get_provider_types, only: [:index]
  before_action :get_states, only: [:index]

  require 'csv'

  def index
    @page     = params[:page] || 1
    @per_page = params[:per_page] || 100

    @q = ProviderPersonalInformation.ransack(params[:q]&.except(:advanced_search))

    @provider_personal_informations =
      @q.result(distinct: true)
        .includes(pdf_generation_queues: :saved_profile)
        .order(first_name: params[:sort] == 'desc' ? :desc : :asc)
        .paginate(per_page: @per_page, page: @page)

    @latest_saved_profiles =
      @provider_personal_informations.map do |provider|
        latest_queue =
          provider.pdf_generation_queues
                  .includes(:saved_profile)
                  .where.not(saved_profile: { id: nil })
                  .order(created_at: :desc)
                  .find(&:saved_profile)

        [provider.id, latest_queue.saved_profile] if latest_queue
      end.compact.to_h
  end

  # ============================
  # CHART DATA (Doughnut + Bar)
  # ============================
  def doughnut_data
    scope = date_scope

    statuses = [
      "attested",
      "no-application",
      "complete-application",
      "incomplete",
      "pending",
      "in-process",
      "psv",
      "returned"
    ]

    status_scope_map = {
      "attested"             => ProviderPersonalInformation.attested,
      "no-application"       => ProviderPersonalInformation.no_application,
      "complete-application" => ProviderPersonalInformation.complete_application,
      "incomplete"           => ProviderPersonalInformation.incomplete,
      "pending"              => ProviderPersonalInformation.pending,
      "in-process"           => ProviderPersonalInformation.in_process,
      "psv"                  => ProviderPersonalInformation.psv,
      "returned"             => ProviderPersonalInformation.returned
    }

    counts = statuses.map do |status|
      scope.merge(status_scope_map[status]).count
    end

    total = counts.sum.nonzero? || 1

    percentages = counts.map do |count|
      ((count.to_f / total) * 100).round(1)
    end

    render json: {
      counts: counts,
      percentages: percentages,
      total: total
    }
  end

  # ============================
  # DATE-BASED PROVIDER SCOPE
  # ============================
  def date_scope
    ProviderPersonalInformation.where(updated_at: date_range(:filter))
  end

  # ============================
  # weekly_count CARDS (Monthly / Weekly / Today)
  # ============================
  def weekly_count
    range = date_range(:range)

    scope = ProviderPersonalInformation.where(updated_at: range)
    created_scope = ProviderPersonalInformation.where(created_at: range)

    render json: {
      # CREATED BASED
      new_providers: created_scope.count,

      # PROGRESS STATUS BASED
      unassigned_providers: scope.to_be_assigned.count,
      assigned_providers:   scope.assigned.count,
      completed_providers:  scope.completed.count,

      # STATUS BASED
      terminated_providers: scope.where(status: 'terminated').count,
      votes:                scope.where(status: 'voted').count
    }
  end

  # ============================
  # DATE RANGE HELPER (SHARED)
  # ============================
  protected

  def date_range(param_key = :filter)
    filter = params[param_key].presence || "monthly"

    case filter
    when "today"
      Time.zone.today.beginning_of_day..Time.zone.now
    when "weekly", "this_week"
      Time.zone.now.beginning_of_week..Time.zone.now
    else # monthly / this_month
      Time.zone.now.beginning_of_month..Time.zone.now
    end
  end

  # ============================
  # CSV + OTHER METHODS
  # (UNCHANGED — SAFE)
  # ============================
  def upload_csv
    @csv_data    = session[:csv_data] || []
    @csv_headers = @csv_data.first
    @csv_data    = @csv_data.drop(1)
  end

  def process_csv
    uploaded_file = params[:file]
    return redirect_to upload_csv_mhc_client_portal_index_path, alert: "No file selected." unless uploaded_file

    if uploaded_file.size.to_f / 1024 > 4
      return redirect_to upload_csv_mhc_client_portal_index_path,
                         alert: "File size exceeds the limit of 4KB."
    end

    session[:csv_data] = CSV.parse(uploaded_file.read, headers: true).to_a
    redirect_to upload_csv_mhc_client_portal_index_path
  rescue
    redirect_to upload_csv_mhc_client_portal_index_path,
                alert: "Invalid CSV format."
  end

  def clear_csv
    session.delete(:csv_data)
    redirect_to upload_csv_mhc_client_portal_index_path,
                notice: "CSV data cleared successfully"
  end

  def show
    @download_histories =
      DownloadHistory.order(downloaded_at: :desc)
                     .paginate(per_page: 10, page: params[:page] || 1)
  end

  def get_provider_types
    @provider_types = ProviderType.all
  end

  def get_states
    @states = State.all
  end

  def redirect_to_auto_verify
    redirect_to auto_verifies_path if current_setting.dcs?
  end
end
