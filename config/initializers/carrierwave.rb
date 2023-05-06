CarrierWave.configure do |config|
	config.fog_provider = 'fog/aws'
	config.fog_credentials = {
			:provider               => 'AWS',
			:aws_access_key_id      => 'DO00YXG3V8H36ZZ2D88H',
			:aws_secret_access_key  => 'A58Es/YqAStl54gtcwnkKVnau7wYwgwCEog/mcW/2J0',
			:region                 => 'nyc3',
			:endpoint               => 'https://nyc3.digitaloceanspaces.com'
	}
	config.fog_directory  = 'plmhealthoneapp'
	config.storage = :fog
	config.asset_host = "https://plmhealthoneapp.nyc3.digitaloceanspaces.com"
	config.fog_attributes = { cache_control: "public, max-age=#{365.days.to_i}" }
end