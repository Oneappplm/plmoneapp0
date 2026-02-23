require 'csv'

class Mhc::WorkTicklersController < ApplicationController
	before_action :load_providers, only: [:index, :privileges, :enrollment_work_tickler]

  PER_PAGE = 10
  DEA_EXPIRING_YEARS = 5
  SPECIALTY_EXPIRING_YEARS = 5
  CDS_EXPIRING_YEARS = 5
  LICENSE_EXPIRING_YEARS = 5

  TAB_MAP = {
	  'Liability'           => 'liability',
	  'License'             => 'licensure',
	  'Board Certification' => 'board_cert_info'
	}.freeze

  def index
  end

  def privileges
    render :privileges_work_tickler
  end

  def enrollment_work_tickler
    render :enrollment_work_tickler
  end

  def dea_expired
    @expired_deas = fetch_deas(:expired)

    respond_to do |format|
      format.html
      format.csv { send_dea_csv(@expired_deas, 'dea_expired') }
    end
  end

  def dea_expiring
    @expiring_deas = fetch_deas(:expiring)

    respond_to do |format|
      format.html
      format.csv { send_dea_csv(@expiring_deas, 'dea_expiring') }
    end
  end

  def board_cert_expired
	  @expired_specialties = fetch_specialties(:expired)

	  respond_to do |format|
	    format.html
	    format.csv { send_specialty_csv(@expired_specialties, 'specialty_expired') }
	  end
	end

	def board_cert_expiring
	  @expiring_specialties = fetch_specialties(:expiring)

	  respond_to do |format|
	    format.html
	    format.csv { send_specialty_csv(@expiring_specialties, 'specialty_expiring') }
	  end
	end

	def provider_cd_expired
	  @expired_cds = fetch_provider_cds(:expired)

	  respond_to do |format|
	    format.html
	    format.csv { send_provider_cd_csv(@expired_cds, 'provider_cd_expired') }
	  end
	end

	def provider_cd_expiring
	  @expiring_cds = fetch_provider_cds(:expiring)

	  respond_to do |format|
	    format.html
	    format.csv { send_provider_cd_csv(@expiring_cds, 'provider_cd_expiring') }
	  end
	end

	def provider_license_expired
	  @expired_licenses = fetch_provider_licenses(:expired)

	  respond_to do |format|
	    format.html
	    format.csv { send_provider_license_csv(@expired_licenses, 'provider_license_expired') }
	  end
	end

	def provider_license_expiring
	  @expiring_licenses = fetch_provider_licenses(:expiring)

	  respond_to do |format|
	    format.html
	    format.csv { send_provider_license_csv(@expiring_licenses, 'provider_license_expiring') }
	  end
	end

	def practitioner_record_expired
	  @records = build_unified_records(:expired)

	  respond_to do |format|
	    format.html
	    format.csv do
	      send_data generate_practitioner_records_csv(@records),
	                filename: "practitioner_records_expired_#{Date.current}.csv"
	    end
	  end
	end

	def practitioner_record_expiring
	  @records = build_unified_records(:expiring)

	  respond_to do |format|
	    format.html
	    format.csv do
	      send_data generate_practitioner_records_csv(@records),
	                filename: "practitioner_records_expiring_#{Date.current}.csv"
	    end
	  end
	end

	def provider_insurance_expired
	  @expired_insurances = fetch_provider_insurances(:expired)

	  respond_to do |format|
	    format.html
	    format.csv do
	      send_data generate_provider_insurance_csv(@expired_insurances),
	                filename: "provider_insurance_expired_#{Date.current}.csv"
	    end
	  end
	end

	def provider_insurance_expiring
	  @expiring_insurances = fetch_provider_insurances(:expiring)

	  respond_to do |format|
	    format.html
	    format.csv do
	      send_data generate_provider_insurance_csv(@expiring_insurances),
	                filename: "provider_insurance_expiring_#{Date.current}.csv"
	    end
	  end
	end

  private

  def load_providers
    @q =
      ProviderPersonalInformation
        .where.not(cred_status: 'no-application')
        .or(ProviderPersonalInformation.where(cred_status: nil))
        .ransack(params[:q])
  end

  def fetch_deas(type)
    scope =
      ProviderDea
        .where(show_on_tickler: ['Yes', nil])
        .includes(provider_attest: :provider_personal_informations)
        .order(expiration_date: :asc)

    scope =
      case type
      when :expired
        scope.where('expiration_date < ?', Date.current)
      when :expiring
        scope.where(expiration_date: Date.current..DEA_EXPIRING_YEARS.years.from_now)
      end

    scope.paginate(per_page: PER_PAGE, page: params[:page] || 1)
  end

  def fetch_specialties(type)
	  scope =
	    ProviderSpecialty
	      .shown_on_tickler
	      .includes(provider_attest: :provider_personal_informations)
	      .order(expiration_date: :asc)

	  scope =
	    case type
	    when :expired
	      scope.where('expiration_date < ?', Date.current)
	    when :expiring
	      scope.where(expiration_date: Date.current..SPECIALTY_EXPIRING_YEARS.years.from_now)
	    end

	  scope.paginate(per_page: PER_PAGE, page: params[:page] || 1)
	end

	def fetch_provider_cds(type)
	  scope =
	    ProviderCd
	      .shown_on_tickler
	      .includes(provider_attest: :provider_personal_informations)
	      .order(expiration_date: :asc)

	  scope =
	    case type
	    when :expired
	      scope.where('expiration_date < ?', Date.current)
	    when :expiring
	      scope.where(expiration_date: Date.current..CDS_EXPIRING_YEARS.years.from_now)
	    end

	  scope.paginate(per_page: PER_PAGE, page: params[:page] || 1)
	end

	def fetch_provider_licenses(type)
	  scope =
	    ProviderLicensure
	      .shown_on_tickler
	      .includes(:state, provider_attest: :provider_personal_informations)
	      .order(license_expiration_date: :asc)

	  scope =
	    case type
	    when :expired
	      scope.where('license_expiration_date < ?', Date.current)
	    when :expiring
	      scope.where(
	        license_expiration_date: Date.current..LICENSE_EXPIRING_YEARS.years.from_now
	      )
	    end

	  scope.paginate(per_page: PER_PAGE, page: params[:page] || 1)
	end

	def fetch_provider_insurances(type)
	  scope =
	    ProviderInsuranceCoverage
	      .shown_on_tickler
	      .includes(provider_attest: :provider_personal_informations)
	      .order(end_date: :asc)

	  scope =
	    case type
	    when :expired
	      scope.where('end_date < ?', Date.current)
	    when :expiring
	      scope.where(end_date: Date.current..5.year.from_now)
	    end

	  scope.paginate(per_page: PER_PAGE, page: params[:page] || 1)
	end

	# for board_cert, liability & license
	def fetch_generic_records(model:, type:, date_column:, years:)
	  scope =
	    model
	      .shown_on_tickler
	      .includes(provider_attest: :provider_personal_informations)
	      .order(date_column => :asc)

	  scope =
	    case type
	    when :expired
	      scope.where("#{date_column} < ?", Date.current)
	    when :expiring
	      scope.where("#{date_column} BETWEEN ? AND ?",
	                  Date.current,
	                  years.years.from_now)
	    end

	  scope.paginate(per_page: PER_PAGE, page: params[:page] || 1)
	end

	def build_unified_records(type)
	  records = []

	  specialty_counts =
	    ProviderSpecialty.group(:provider_attest_id).count

	  insurance_counts =
	    ProviderInsuranceCoverage.group(:provider_attest_id).count

	  licensure_counts =
	    ProviderLicensure.group(:provider_attest_id).count

	  # Board Certification
	  fetch_generic_records(
	    model: ProviderSpecialty,
	    type: type,
	    date_column: :expiration_date,
	    years: SPECIALTY_EXPIRING_YEARS
	  ).each do |r|
	    records << build_row(
	      r,
	      'Board Certification',
	      r.specialty_specialty_name,
	      r.expiration_date,
	      specialty_counts[r.provider_attest_id] || 0
	    )
	  end

	  # Insurance Coverage
	  fetch_generic_records(
	    model: ProviderInsuranceCoverage,
	    type: type,
	    date_column: :end_date,
	    years: 1
	  ).each do |r|
	    records << build_row(
	      r,
	      'Liability',
	      r.insurance_carrier_name,
	      r.end_date,
	      insurance_counts[r.provider_attest_id] || 0
	    )
	  end

	  # Licensure
	  fetch_generic_records(
	    model: ProviderLicensure,
	    type: type,
	    date_column: :license_expiration_date,
	    years: LICENSE_EXPIRING_YEARS
	  ).each do |r|
	    records << build_row(
	      r,
	      'License',
	      r.license_type,
	      r.license_expiration_date,
	      licensure_counts[r.provider_attest_id] || 0
	    )
	  end

	  records.sort_by { |r| r[:expiration_date] }
	end

	def build_row(record, tab_name, record_name, expiration_date, record_count)
	  provider = record.provider_attest&.provider_personal_informations&.first

	  {
	    practitioner_name: provider&.fullname || 'N/A',
	    tab_name: tab_name,
	    page_tab: TAB_MAP[tab_name],
	    record_num: record_count,
	    record_name: record_name,
	    expiration_date: expiration_date,
	    department: nil,
	    provider_attest_id: record.provider_attest_id
	  }
	end


  # CSV Export for DEA
  def send_dea_csv(deas, filename_prefix)
    send_data generate_dea_csv(deas),
              filename: "#{filename_prefix}_#{Date.current}.csv"
  end

  def generate_dea_csv(deas)
    CSV.generate(headers: true) do |csv|
      csv << csv_headers

      deas.each_with_index do |dea, index|
        provider = dea.provider_attest&.provider_personal_informations&.first

        csv << [
          index + 1,
          provider&.fullname || 'N/A',
          dea.dea_number,
          dea.expiration_date&.strftime('%m/%d/%Y'),
          provider&.fullname || 'N/A',
          provider&.cell_phone_number || 'N/A',
          provider&.fax_number || 'N/A',
          nil
        ]
      end
    end
  end

  def csv_headers
    [
      'Sr',
      'Practitioner Name',
      'DEA Number',
      'Expiration Date',
      'Credentials Contact Name',
      'Credentials Contact Phone',
      'Credentials Contact Fax',
      'Department/Division'
    ]
  end

  # CSV Export for board certification
  def send_specialty_csv(records, filename_prefix)
	  send_data generate_specialty_csv(records),
	            filename: "#{filename_prefix}_#{Date.current}.csv"
	end

	def generate_specialty_csv(records)
	  CSV.generate(headers: true) do |csv|
	    csv << specialty_csv_headers

	    records.each_with_index do |specialty, index|
	      provider = specialty.provider_attest&.provider_personal_informations&.first

	      csv << [
	        index + 1,
	        provider&.fullname || 'N/A',
	        specialty.specialty_specialty_name,
	        specialty.specialty_board_name,
	        specialty.expiration_date&.strftime('%m/%d/%Y'),
	        provider&.fullname || 'N/A',
	        provider&.cell_phone_number || 'N/A',
	        provider&.fax_number || 'N/A',
	        nil
	      ]
	    end
	  end
	end

	def specialty_csv_headers
	  [
	    'Sr',
	    'Practitioner Name',
	    'Specialty',
	    'Issuing Board',
	    'Expiration Date',
	    'Credentials Contact Name',
	    'Credentials Contact Phone',
	    'Credentials Contact Fax',
	    'Department/Division'
	  ]
	end

	# CSV Export for provider_cds 
	def send_provider_cd_csv(cds, filename_prefix)
  send_data generate_provider_cd_csv(cds),
            filename: "#{filename_prefix}_#{Date.current}.csv"
	end

	def generate_provider_cd_csv(cds)
	  CSV.generate(headers: true) do |csv|
	    csv << [
	      'Sr',
	      'Practitioner Name',
	      'CDS Number',
	      'State',
	      'Expiration Date',
	      'Credentials Contact Name',
	      'Credentials Contact Phone',
	      'Credentials Contact Fax',
	      'Department/Division'
	    ]

	    cds.each_with_index do |cd, index|
	      provider = cd.provider_attest&.provider_personal_informations&.first

	      csv << [
	        index + 1,
	        provider&.fullname || 'N/A',
	        cd.cds_number,
	        cd.state,
	        cd.expiration_date&.strftime('%m/%d/%Y'),
	        provider&.fullname || 'N/A',
	        provider&.cell_phone_number || 'N/A',
	        provider&.fax_number || 'N/A',
	        nil
	      ]
	    end
	  end
	end

	# CSV Export for provider_licensure
	def send_provider_license_csv(licenses, filename_prefix)
	  send_data generate_provider_license_csv(licenses),
	            filename: "#{filename_prefix}_#{Date.current}.csv"
	end

	def generate_provider_license_csv(licenses)
	  CSV.generate(headers: true) do |csv|
	    csv << provider_license_csv_headers

	    licenses.each_with_index do |license, index|
	      provider = license.provider_attest&.provider_personal_informations&.first

	      csv << [
	        index + 1,
	        provider&.fullname || 'N/A',
	        license.state&.name,
	        license.license_number,
	        license.is_primary_license? ? 'Yes' : 'No',
	        license.license_expiration_date&.strftime('%m/%d/%Y'),
	        provider&.fullname || 'N/A',
	        provider&.cell_phone_number || 'N/A',
	        provider&.fax_number || 'N/A',
	        nil
	      ]
	    end
	  end
	end

	def provider_license_csv_headers
	  [
	    'Sr',
	    'Practitioner Name',
	    'State',
	    'License Number',
	    'Primary License',
	    'Expiration Date',
	    'Credentials Contact Name',
	    'Credentials Contact Phone',
	    'Credentials Contact Fax',
	    'Department/Division'
	  ]
	end

	# CSV Export for board_cert, liability & license
	def generate_practitioner_records_csv(records)
	  CSV.generate(headers: true) do |csv|
	    csv << practitioner_records_csv_headers

	    records.each_with_index do |row, index|
	      csv << [
	        index + 1,
	        row[:practitioner_name],
	        row[:tab_name],
	        row[:record_num],
	        row[:record_name],
	        row[:expiration_date]&.strftime('%m/%d/%Y'),
	        row[:department]
	      ]
	    end
	  end
	end

	def practitioner_records_csv_headers
	  [
	    'Sr.',
	    'Practitioner Name',
	    'Tab Name',
	    'Record Count',
	    'Record Name',
	    'Expiration Date',
	    'Department/Division'
	  ]
	end

	# CSV Export for Provider Insurance Coverages
	def generate_provider_insurance_csv(insurances)
	  CSV.generate(headers: true) do |csv|
	    csv << provider_insurance_csv_headers

	    insurances.each_with_index do |insurance, index|
	      provider =
	        insurance.provider_attest&.provider_personal_informations&.first

	      csv << [
	        index + 1,
	        provider&.fullname || 'N/A',
	        insurance.insurance_carrier_name,
	        insurance.end_date&.strftime('%m/%d/%Y'),
	        provider&.fullname || 'N/A',
	        provider&.cell_phone_number || 'N/A',
	        provider&.fax_number || 'N/A',
	        nil
	      ]
	    end
	  end
	end

	def provider_insurance_csv_headers
	  [
	    'Sr',
	    'Practitioner Name',
	    'Policy Number',
	    'Expiration Date',
	    'Credentials Contact Name',
	    'Credentials Contact Phone',
	    'Credentials Contact Fax',
	    'Department/Division'
	  ]
	end
end
