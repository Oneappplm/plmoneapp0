class WorkTicklersController < ApplicationController

  def index
    if params[:committee_date].present?
      committee_date_search = params[:committee_date].strip.downcase

      matching_committees = VirtualReviewCommittee.where("TO_CHAR(committee_date, 'YYYY-MM-DD') LIKE ?", "%#{committee_date_search}%")
  
      if matching_committees.present?
        # Collect all provider_ids from the matching VirtualReviewCommittee records
        provider_ids = matching_committees.pluck(:provider_id)
  
        # Find all providers with the matching provider_ids
        @providers = Provider.unscoped
          .select("CASE WHEN first_name = '' THEN NULL ELSE first_name END as f,
                   CASE WHEN last_name = '' THEN NULL ELSE last_name END as l,
                   CASE WHEN middle_name = '' THEN NULL ELSE middle_name END as m, *")
          .where(id: provider_ids)
      else
        @providers = Provider.none
      end
  
    else
      @providers = if current_user.provider?
        accessible_provider_id = current_user.accessible_provider.blank? ? 0 : current_user.accessible_provider
  
        Provider.unscoped
          .select("CASE WHEN first_name = '' THEN NULL ELSE first_name END as f,
                   CASE WHEN last_name = '' THEN NULL ELSE last_name END as l,
                   CASE WHEN middle_name = '' THEN NULL ELSE middle_name END as m, *")
          .where(id: accessible_provider_id)
          .all
      else
        Provider.unscoped
          .select("CASE WHEN first_name = '' THEN NULL ELSE first_name END as f,
                   CASE WHEN last_name = '' THEN NULL ELSE last_name END as l,
                   CASE WHEN middle_name = '' THEN NULL ELSE middle_name END as m, *")
          .all
      end
    end
  
    if !current_user.can_access_all_groups? && !current_user.super_administrator? && !current_user.provider? && !sprout_staff_admin(current_user)
      @providers = @providers.where(enrollment_group_id: current_user.enrollment_groups.pluck(:id))
    end
  
    @providers = @providers.reorder("f asc NULLS last", "m asc NULLS last", "l asc NULLS last")
    @providers_without_pagination = @providers
  
    @providers = @providers.paginate(per_page: 10, page: params[:page] || 1)
  
    @providers = @providers.reorder("f asc NULLS last", "m asc NULLS last", "l asc NULLS last").paginate(per_page: 10, page: params[:page] || 1)
  end
end
