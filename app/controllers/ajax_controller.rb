class AjaxController < ApplicationController

  def delete_record
    # render json: params and return
    id = params[:id]
    model = params[:model]
    if model == 'licenses'
      ProviderLicense.delete(id)
    elsif model == 'taxonomies'
      ProviderTaxonomy.delete(id)
    elsif model == 'np_licenses'
      ProviderNpLicense.delete(id)
    elsif model == 'rn_licenses'
      ProviderRnLicense.delete(id)
    end

    head :ok
  end

  def get_group_dcos
    id = params[:group_id]
    group = EnrollmentGroup.find_by(id: id) if params[:group_id] != 'all'
    group_dco =  ( params[:group_id] != 'all' ? group.dcos.count : EnrollmentGroup.count )

    render json: {
      'group_dco' => group_dco
    }
  end

  def get_provider_payers
    id = params[:provider_id]
    provider = EnrollmentProvider.find_by(id: id)
    # render json: provider.details and return
    # render json: params and return

    render json: {
      'submitted' => provider.details.submitted.count,
      'processing' => provider.details.processing.count,
      'approved' =>  provider.details.approved.count,
      'denied' => provider.details.denied.count,
      'terminated' => provider.details.terminated.count
    }
  end

  def get_enrollment_status_count
    model = params[:model]
    status = params[:status]
    count = if model == 'enrollment_providers'
      EnrollmentProvider.send(status).count
    elsif model == 'enroll_groups'
      EnrollGroup.send(status).count
    else
      0
    end
    render json: {
      'count' => count
    }
  end

  def change_enrollment_status
    id = params[:id]
    model = params[:model]
    status = params[:status]
    enrollment_type = if model == 'enrollment_providers'
        EnrollmentProvider.find_by(id: id)
    end

    enrollment_type.update_attribute('status', status) if enrollment_type

    render json: {
      'status' => enrollment_type.status.titleize,
      'id' => enrollment_type.id
    }
  end
end