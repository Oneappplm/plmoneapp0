# frozen_string_literal: true

namespace	:client do
	desc	"Add client seed data"
	task	:seed_data	=>	:environment	do
		Client.destroy_all
		Import::ClientService.call(Rails.root.join('lib', 'data', 'clients.csv'))
	end
end