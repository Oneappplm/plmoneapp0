class Directory < ApplicationRecord
	default_scope { order(:name)}

	def self.generate_directories
		directories = ['OneHealthPort Statewide Provider Directory']

		directories.each do |directory|
			if !Directory.exists?(name: directory.strip)
				Directory.create(name: directory.strip)
			end
		end
	end
end