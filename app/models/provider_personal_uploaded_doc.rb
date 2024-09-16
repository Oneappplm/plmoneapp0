class ProviderPersonalUploadedDoc < ApplicationRecord
	belongs_to :provider_attest

	mount_uploader :file_upload, DocumentUploader

	enum image_classification: {
		client_uploaded_documents: 'Client Uploaded Documents',
		received_request: 'Received Request',
		received_verification: 'Received Verification',
		profile: 'Profile',
		personal_signature: 'Personal Signature',
		personal_photo: 'Personal Photo',
		release: 'Release',
		application: 'Application',
		dop: 'DOP'
	}

	enum sub_section: {
		accreditation: 'Accreditation - Accreditation',
		certification: 'Certification - Certification',
		fsmb: 'FSMB - FSMB',
		clia: 'III - CLIA',
		education: 'IV - Education',
		epls: 'MedicareOrMedicaid - EPLS',
		ownership: 'MedicareOrMedicaid - Ownership',
		npdb: 'NPDB - NPDB',
		oig: 'OIG - OIG',
		sitevisit: 'SiteVisit - SiteVisit',
		training: 'V - Training',
		teaching_appointments: 'VII - Teaching Appointments',
		board_certification: 'VIII - Board Certification',
		cdsdps: 'X - CDS/DPS',
		dea: 'X - DEA',
		ecfmg: 'X - ECFMG',
		licensure: 'Licensure',
		liability_coverage: 'XII - Liability Coverage',
		facilities: 'XIII - Facilities',
		peer_reference: 'XIV - Peer Reference',
		employment_history: 'XV - Employment History'
	}
end
