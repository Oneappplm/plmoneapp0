module RemovePayorFiles
	extend ActiveSupport::Concern

 included do
		def remove_upload_payor_files!
				details.each do |detail|
						next if detail.upload_payor_file.present?

						detail.remove_upload_payor_file!
				end
		end
	end
end
