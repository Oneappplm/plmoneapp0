class MultiSelectDataController < ApplicationController
	def states
		send_result State.all.map{|m| { label: m.name, value: m.name} }
	end

	def provider_types
		send_result ProviderType.all.map{|ptype| { label: ptype.fch, value: ptype.fch} }
	end

	def	countries
		send_result Country.all_translated.map{|country| { label: country, value: country} }
	end

	def visa_types
		send_result VisaType.all.map{|visa| { label: visa.name, value: visa.name} }
	end

	def languages
		send_result	Language.all.map(&:name)
	end

	# add more methods here

	private

	def send_result data
		render json: { 'result' => data }
	end
end
