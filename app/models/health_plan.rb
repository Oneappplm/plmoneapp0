class HealthPlan < ApplicationRecord

	default_scope { order(:name)}

	def self.generate_plans
		plans = ['Aetna via NaviNet', 'Amerigroup Corporation', 'Amplifon Hearing Health Care',
				 'Avesis Incorporated', 'Cenpatico', 'Columbia United Providers', 'Coordinated Care',
				 'Coventry Health Care Workers Compensation Inc', 'DentalQuest', 'Eye Med Vision Care',
				 'GEHA', 'Guardian Life Insurance Company of America', 'Kaiser Permanente Washington',
				 'LifeWise Health Plan', 'Molina Healthcare', 'Northwest Rehab Alliance', 'Optum - Physical Health',
				 'PacificSource Health Plans (WA State only)', 'Planned Parenthood of the Great Northwest and the Hawaiian Islands',
				 'Principal Life Insurance Co-Dental', 'Providence Plan Partners', 'QualChoice Health Plan Services, Inc', 'Star Hearing',
				 'The CHP Group', 'Tivity Health', 'United Concordia Dental', 'UnitedHealthcare - Medical', 'Versant Health', 'Vision Service Plan',
				 'Wholehealth Living, Inc', 'American Specialty Health', 'AMERITAS', 'Asuris Northwest Health', 'CAREINGTON INTERNATIONAL CORPORATION',
				 'CIGNA', 'Community Health Plan of WA', 'Coventry Health Care', 'Delta Dental of Washington', 'Eye Med Vision Care',
				 'First Choice Health', 'Great Rivers Behavioral Health Organization', 'Health Net Federal Services', 'LeggUP Inc.',
				 'MCNA Dental', 'National Vision', 'Optum - Behavioral Health', 'Optum Care Network', 'Physicians of Southwest Washington',
				 'Premera Blue Cross', 'PROGYNY', 'Public Health Seattle-King County', 'Regence BlueShield', 'Starmount-Unum', 'Therapeutic Associates',
				 'U.S. VISION', 'UnitedHealthcare - Dental', 'UnitedHealthcare - Vision - Spectera Eyecare Networks', 'Vision Benefits of America',
				 'Washington Department of Labor and Industries (L&I)', 'Willamette Dental Group'
				]

		plans.each do |plan|
			if !HealthPlan.exists?(name: plan.strip)
				HealthPlan.create(name: plan.strip)
			end
		end
	end

end