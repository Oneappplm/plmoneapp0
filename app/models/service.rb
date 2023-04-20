class Service < ApplicationRecord
  default_scope { order(name: :asc)}

	def self.generate_services
		services = [
                 'Acupuncture - SUD', 'Age Appropriate Immunizations', 'Allergy Injections', 'Allergy Skin Testing',
                'Assertive Community Treatment (ACT)*', 'Assessments', 'Asthma Treatment', 'Autism Services/Applied Behavioral Analysis',
                'Behavioral', 'Behavioral Health Treatment Plan', 'Cardiac Stress Tests', 'Club house/Psychosocial Rehabilitation*',
                'Community Living Support', 'Community Transition (Waiver for Children-SED only) ', 'Crisis Intervention', 'Crisis Residential Services* ',
                'Day Program Sites*', 'Drawing Blood', 'Drop In Center Programs* ', 'EKG', 'Family Training', 'Fiscal Intermediary', 'Flexible Sigmoidoscopy',
                'Foster Care, Therapeutic (SEDW only) Health Services', 'Home-Based Services* ', 'Inpatient Mental Health ', 'Intensive Crisis Stabilization* ',
                'IV Hydration/Treatment', 'Medication Administration Medication Review', 'Mental Health Individual, Family and Group Therapy - Adult ', 'Mental Health Individual, Family and Group Therapy - Child',
                'Minor Lacerations', 'Nursing Facility Mental Health Monitoring ', 'Obstetric including birthing', 'Occupational Therapy', 'Osteopathic Manipulation',
                'Other', 'Partial Hospitalization', 'Pediatric', 'Peer Directed and Operated Support Services', 'Personal Care in Licensed Specialized Residential Setting', 'Physical Therapy',
                'Prevention Services - Direct Model', 'Private Duty Nursing', 'Pulmonary Function Testing', 'Radiology', 'Respite Care Services', 'Respite Care Services, not in home',
                'Routine Gynecology (Pelvic/Pap)', 'Skill Building ', "Specialty Services (Children's Waiver & Waiver for Children w/SED only)", 'Speech/Language', 'SUD Individual Assessment',
                'SUD Intensive Outpatient ', 'SUD Methadone', 'SUD Outpatient Care', 'SUD Prevention Services', 'SUD Recovery Home ',
                'SUD Residential Services', 'SUD-Acute Detoxification', 'Supported Employment Services', 'Supportive Housing', 'Supports Coordination ',
                'Targeted Case Management', 'Telemedicine', 'Therapy (Mental Health) Child & Adult, Individual, Family Group ', 'Transportation',
                'Tympanometry/Audiometry Screening', "Women's healthcare", 'Wraparound Services*'
    ]

    services.each do |service|
      Service.find_or_create_by(name: service.strip)
    end
	end
end