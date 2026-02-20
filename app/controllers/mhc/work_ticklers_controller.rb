require 'csv'

class Mhc::WorkTicklersController < ApplicationController
  PER_PAGE = 10
  DEA_EXPIRING_YEARS = 5
  SPECIALTY_EXPIRING_YEARS = 5

  def index
    @q = ProviderPersonalInformation
           .where.not(cred_status: 'no-application')
           .or(ProviderPersonalInformation.where(cred_status: nil))
           .ransack(params[:q])
  end

  def privileges
  	@q = ProviderPersonalInformation
           .where.not(cred_status: 'no-application')
           .or(ProviderPersonalInformation.where(cred_status: nil))
           .ransack(params[:q])
    render :privileges_work_tickler
  end

  def enrollment_work_tickler
  	@q = ProviderPersonalInformation
           .where.not(cred_status: 'no-application')
           .or(ProviderPersonalInformation.where(cred_status: nil))
           .ransack(params[:q])
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

  private

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
	      scope.where(expiration_date: Date.current..DEA_EXPIRING_YEARS.years.from_now)
	    end

	  scope.paginate(per_page: PER_PAGE, page: params[:page] || 1)
	end

  # CSV Export
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

  # for board certification
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

	# for provider_cds 
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

end
