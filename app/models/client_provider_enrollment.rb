class ClientProviderEnrollment < ApplicationRecord
  belongs_to :enrollable, polymorphic: true

  class << self
    def search_by_params(params)
      enrollable_type_condition = "WHERE cpe.enrollable_type IN ('EnrollGroup','EnrollmentProvider')"

      if params[:enrollable_type].present? && params[:enrollable_type] != "all"
        enrollable_type_condition = "WHERE cpe.enrollable_type = '#{params[:enrollable_type]}'"
      end

      if params[:enrollment_group_ids].present?
        enrollment_group_ids_condition = " AND (emg.id IN (#{params[:enrollment_group_ids].map{|s| "'#{s.to_s}'"}.join(',')}) AND cpe.enrollable_type = 'EnrollGroup') 
                                           OR (p.enrollment_group_id IN (#{params[:enrollment_group_ids].map{|s| "'#{s.to_s}'"}.join(',')}) AND cpe.enrollable_type = 'EnrollmentProvider'
                                                AND ep.outreach_type = 'provider-from-enrollment')
                                           OR (ep.outreach_type = 'provider-from-provider-app')"
      end

      if params[:search_keyword].present?
        keyword_condition = " WHERE (LOWER(cpe_inner.group_name) LIKE LOWER(:state) AND cpe.enrollable_type = 'EnrollGroup') OR
                                    ((LOWER(cpe_inner.provider_full_name) LIKE LOWER(:state) OR LOWER(cpe_inner.provider_partial_name) LIKE LOWER(:state)
                                      OR cpe_inner.provider_ssn LIKE LOWER(:state) OR cpe_inner.provider_npi LIKE LOWER(:state)) AND cpe.enrollable_type = 'EnrollmentProvider')"
      end

      sql_string = "SELECT cpe.*, case
                            when cpe.enrollable_type = 'EnrollmentProvider' then cpe_inner.provider_full_name
                            else cpe_inner.group_name
                            end as name
                            FROM client_provider_enrollments cpe
                            INNER JOIN (SELECT cpe.id as id,
                                case when ep.outreach_type = 'provider-from-enrollment'
                                then NULLIF(TRIM(CONCAT(p.first_name,' ',p.middle_name,' ',p.last_name)),'')
                                else NULLIF(string_agg(psd.data_value, ' '),'')
                                end as provider_full_name,
                                NULLIF(TRIM(CONCAT(p.first_name,' ',p.last_name)), '') as provider_partial_name,
                                NULLIF(emg.group_name,'') as group_name,
                                p.ssn as provider_ssn,
                                p.npi as provider_npi
                              FROM client_provider_enrollments cpe
                              LEFT JOIN enroll_groups eg ON cpe.enrollable_id = eg.id AND cpe.enrollable_type = 'EnrollGroup'
                              LEFT JOIN enrollment_groups emg ON emg.id = eg.group_id
                              LEFT JOIN enrollment_providers ep ON cpe.enrollable_id = ep.id AND cpe.enrollable_type = 'EnrollmentProvider'
                              LEFT JOIN providers p ON p.id = ep.provider_id AND ep.outreach_type = 'provider-from-enrollment'
                              LEFT JOIN provider_sources ps ON ps.id = ep.provider_id AND ep.outreach_type = 'provider-from-provider-app'
                              LEFT JOIN provider_source_data psd ON ps.id = psd.provider_source_id AND (psd.data_key = 'first_name' OR psd.data_key = 'last_name')
                              #{enrollable_type_condition} #{enrollment_group_ids_condition}
                              GROUP BY cpe.id, ep.outreach_type, p.first_name, p.middle_name, p.last_name, emg.group_name, p.ssn, p.npi) as cpe_inner ON cpe_inner.id = cpe.id
                              #{keyword_condition}
                              ORDER BY name ASC NULLS LAST"

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

# in case of issues reapply this working sql string
  # sql_string = "SELECT cpe.*
  #                     FROM client_provider_enrollments cpe
  #                     INNER JOIN (SELECT cpe.id as id,
  #                         TRIM(CONCAT(p.first_name,' ',p.middle_name,' ',p.last_name)) as provider_full_name,
  #                         TRIM(CONCAT(p.first_name,' ',p.last_name)) as provider_partial_name,
  #                         emg.group_name as group_name,
  #                         p.ssn as provider_ssn,
  #                         p.npi as provider_npi
  #                       FROM client_provider_enrollments cpe
  #                       LEFT JOIN enroll_groups eg ON cpe.enrollable_id = eg.id AND cpe.enrollable_type = 'EnrollGroup'
  #                       LEFT JOIN enrollment_groups emg ON emg.id = eg.group_id
  #                       LEFT JOIN enrollment_providers ep ON cpe.enrollable_id = ep.id AND cpe.enrollable_type = 'EnrollmentProvider'
  #                       LEFT JOIN providers p ON p.id = ep.provider_id
  #                       #{enrollable_type_condition}) as cpe_inner ON cpe_inner.id = cpe.id
  #                       #{keyword_condition}"