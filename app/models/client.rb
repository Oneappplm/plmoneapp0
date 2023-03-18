class Client < ApplicationRecord
	before_create :set_full_name
	include PgSearch::Model
	pg_search_scope :search,
                  against: self.column_names,
                  using: {
                    tsearch: {any_word: true}
                  }

   scope :attested, -> { where(cred_status: 'attested') }
   scope :no_application, -> { where(cred_status: 'no-application') }
   scope :complete, -> { where(cred_status: 'complete-application') }
   scope :incomplete, -> { where(cred_status: 'incomplete') }
   scope :pending_data, -> { where(cred_status: 'pending') }
   scope :in_process, -> { where(cred_status: 'in-process') }
   scope :psv, -> { where(cred_status: 'psv') }
   scope :returned, -> { where(cred_status: 'returned') }
   # scope :published, -> { where(:published => true)}

	def self.create_dummies
		providers = ['Hospice Home Care', 'Mercy Medical Center', 'Baptist Health', 'Mayo Clinic', 'Cleveland Clinic', 'Standford Health Care', 'UCLA Health', 'University of Michigan']
	 	statuses = ['attested', 'no-application', 'complete-application', 'incomplete','pending', 'in-process', 'psv', 'returned']
	 	# NPI will be assigned to the 8 providers above
	 	npis = []
		for i in 1..8 do
			npis << Faker::Code.npi
		end
		cred_cycles = ['Recred', 'Cred']

		for i in 1..60 do
			client = Client.new
			client.first_name = Faker::Name.first_name
			client.last_name = Faker::Name.last_name
			client.middle_name = Faker::Name.middle_name
     		client.provider_name = providers[rand(0..7)]
     		client.birth_date = Faker::Date.birthday(min_age: 18, max_age: 50)
     		client.state = Faker::Address.state
     		client.state_abbr = Faker::Address.state_abbr
     		client.street_address = Faker::Address.street_address
     		client.city = Faker::Address.city
     		client.zipcode = Faker::Address.zip_code
     		client.ssn = Faker::IDNumber.valid
     		client.npi = npis[(rand(0..7))]
     		client.attested_date = Faker::Date.between(from: '2008-09-23', to: '2014-09-25')
     		client.provider_type = "Facility"
     		client.specialty = "Physician Assistant".upcase
     		client.cred_status = statuses[rand(0..7)]
     		client.cred_cycle = cred_cycles[(i.odd? ? 0 : 1)]
     		client.medv_id = "MedvId#{rand(1231..2233)}"
     		client.save
		end
	end

	def address
		"#{self.street_address}, #{self.city}, #{self.state_abbr}, #{self.zipcode}"
	end

	def full_name
		"#{self.first_name} #{self.last_name}"
	end

	def social
		"@#{self.first_name.slice(0..2)}_#{self.last_name.slice(0..4)}".downcase
	end

	private

	def set_full_name
		"#{self.first_name} #{self.last_name}"
	end
end
