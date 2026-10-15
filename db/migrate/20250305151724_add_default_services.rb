class AddDefaultServices < ActiveRecord::Migration[7.0]
  def up
    services = [
      "Acupuncture - SUD",
      "Age Appropriate Immunizations",
      "Allergy Injections",
      "Allergy Skin Testing",
      "Assertive Community Treatment (ACT)",
      "Assessments",
      "Asthma Treatment",
      "Autism Services/Applied Behavioral Analysis",
      "Behavioral",
      "Behavioral Health Treatment Plan",
      "Cardiac Stress Tests",
      "Club house/Psychosocial Rehabilitation",
      "Community Living Support",
      "Community Transition (Waiver for Children-SED only)",
      "Crisis Intervention",
      "Crisis Residential Services",
      "Day Program Sites",
      "Drop In Center Programs",
      "EKG",
      "Family Training",
      "Fiscal Intermediary",
      "Flexible Sigmoidoscopy",
      "Foster Care, Therapeutic (SEDW only) Health Services",
      "Intensive Crisis Stabilization",
      "Inpatient Mental Health",
      "Medication Administration Medication Review",
      "Mental Health Individual, Family and Group Therapy - Child",
      "Minor Lacerations",
      "Nursing Facility Mental Health Monitoring",
      "Obstetric Including birthing",
      "Occupational Therapy",
      "Osteopathic Manipulation",
      "Partial Hospitalization",
      "Pediatric",
      "Peer Directed and Operated Support Services",
      "Personal Care in Licensed Specialized Residential Setting",
      "Physical Therapy",
      "Private Duty Nursing",
      "Pulmonary Function Testing",
      "Respite Care Services, not in",
      "Routine Gynecology (Pelvic/Pap)",
      "Skill Building",
      "SUD Individual Assessment",
      "SUD Intensive Outpatient",
      "SUD Methadone",
      "SUD Outpatient Care",
      "SUD Prevention Services",
      "SUD Recovery Home",
      "Supported Employment Services",
      "Supportive Housing",
      "Supports Coordination",
      "Telemedicine",
      "Transportation",
      "Wraparound Services"
    ]    

    services.each do |service_name|
      Service.create(name: service_name)
    end
  end

  def down
    Service.delete_all
  end
end
