class ClientProviderEnrollment < ApplicationRecord
  belongs_to :enrollable, polymorphic: true

  class << self
    def search_by_params(params)
      return all.paginate(per_page: params[:per_page].present? ? params[:per_page] : 20, page:  params[:page].present? ? params[:page] : 1) if params[:search_keyword].blank? && params[:enrollable_type].blank?

      enrollable_type_condition = "WHERE cpe.enrollable_type IN ('EnrollGroup','EnrollmentProvider')"

      if params[:enrollable_type].present? && params[:enrollable_type] != "all"
        enrollable_type_condition = "WHERE cpe.enrollable_type = '#{params[:enrollable_type]}'"
      end

      if params[:search_keyword].present?
        keyword_condition = " WHERE (LOWER(cpe_inner.group_name) LIKE LOWER(:state) AND cpe.enrollable_type = 'EnrollGroup') OR
                                    ((LOWER(cpe_inner.provider_full_name) LIKE LOWER(:state) OR LOWER(cpe_inner.provider_partial_name) LIKE LOWER(:state)
                                      OR cpe_inner.provider_ssn LIKE LOWER(:state) OR cpe_inner.provider_npi LIKE LOWER(:state)) AND cpe.enrollable_type = 'EnrollmentProvider')"
      end

      sql_string = "SELECT cpe.*
                    FROM client_provider_enrollments cpe
                    INNER JOIN (SELECT cpe.id as id,
                        TRIM(CONCAT(p.first_name,' ',p.middle_name,' ',p.last_name)) as provider_full_name,
                        TRIM(CONCAT(p.first_name,' ',p.last_name)) as provider_partial_name,
                        emg.group_name as group_name,
                        p.ssn as provider_ssn,
                        p.npi as provider_npi
                      FROM client_provider_enrollments cpe
                      LEFT JOIN enroll_groups eg ON cpe.enrollable_id = eg.id AND cpe.enrollable_type = 'EnrollGroup'
                      LEFT JOIN enrollment_groups emg ON emg.id = eg.group_id
                      LEFT JOIN enrollment_providers ep ON cpe.enrollable_id = ep.id AND cpe.enrollable_type = 'EnrollmentProvider'
                      LEFT JOIN providers p ON p.id = ep.provider_id
                      #{enrollable_type_condition}) as cpe_inner ON cpe_inner.id = cpe.id
                      #{keyword_condition}"
      sql = <<-SQL
         #{sql_string}
        SQL
      paginate_by_sql(
        [sql, { :state => "%" + (params[:search_keyword].present? ? params[:search_keyword] : "") + "%" }],
        page:  params[:page].present? ? params[:page] : 1,
        per_page: params[:per_page].present? ? params[:per_page] : 20
      )
    end
  end
end
