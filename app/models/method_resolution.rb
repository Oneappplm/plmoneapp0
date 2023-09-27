class MethodResolution < ApplicationRecord

	default_scope { order(:name)}

	def self.generate_method_resolutions
		resolutions = [ 'Ajudicated', 'Arbitrated', 'Awarded', 'Defense Verdict', 'Dismissed', 'Dismissed with prejudice', 'Dismissed without prejudice', 'Dropped/Settled/Closed - no payment', 'Dropped/Settled/Closed with payment', 'In Appeal', 'Judgement', 'Judgement for Defendant', 'Judgement for Plaintiff', 'Mediated', 'Other', 'Pending', 'Settled', 'Settled out of court', 'Settled with Prejudice', 'Settled without Prejudice', 'Trial Date Set - awaiting trial', 'Verdict for plaintiff', 'Verdict for you - no payment', 'Withdrawn'  
				]

        resolutions.each do |resolution|
			if !MethodResolution.exists?(name: resolution.strip)
				MethodResolution.create(name: resolution.strip)
			end
		end
	end

end