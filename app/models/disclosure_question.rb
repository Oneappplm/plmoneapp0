class DisclosureQuestion < ApplicationRecord
	belongs_to :disclosure_category
	before_save :set_slug
	def self.generate_category_question
		category_questions = [
			['Licensure','Has your license, registration or certification to practice in your profession ever been voluntarily or involuntarily relinquished, denied, suspended, revoked, restricted, or have you ever been subject to a fine, reprimand, consent order, probation or any conditions or limitations by any state or professional licensing, registration or certification board?',nil,nil],
			['Licensure','Has there been any challenge to your licensure, registration or certification?',nil,nil],
			['Hospital Privileges and Other Affiliations','Have your clinical privileges or medical staff membership at any hospital or healthcare institution, voluntarily or involuntarily, ever been denied, suspended, revoked, restricted, denied renewal or subject to probationary or to other disciplinary conditions (for reasons other than non-completion of medical record when quality of care was not adversely affected) or have proceedings toward any of those ends been instituted or recommended by any hospital or healthcare institution, medical staff or committee, or governing board?',nil,nil],
			['Hospital Privileges and Other Affiliations','Have you voluntarily or involuntarily surrendered, limited your privileges or not reapplied for privileges while under investigation?',nil,nil],
			['Hospital Privileges and Other Affiliations','Have you ever been terminated for cause or not renewed for cause from participation, or been subject to any disciplinary action, by any managed care organizations (including HMOs, PPOs, or provider organizations such as IPAs, PHOs)?',nil,nil],
			['Education, Training and Board Certification','Were you ever placed on probation, disciplined, formally reprimanded, suspended or asked to resign during an internship, residency, fellowship, preceptorship or other clinical education program? If you are currently in a training program, have you been placed on probation, disciplined, formally reprimanded, suspended or asked to resign?',nil,nil],
			['Education, Training and Board Certification','Have you ever, while under investigation or to avoid an investigation, voluntarily withdrawn or prematurely terminated your status as a student or employee in any internship, residency, fellowship, preceptorship, or other clinical education program?',nil,nil],
			['Education, Training and Board Certification','Have any of your board certifications or eligibility ever been revoked?',nil,nil],
			['Education, Training and Board Certification',' Have you ever chosen not to re-certify or voluntarily surrendered your board certification(s) while under investigation?',nil,nil],
			['DEA or CDS','Have your Federal DEA and/or State Controlled Dangerous Substances (CDS) certificate(s) or authorization(s) ever been challenged, denied, suspended, revoked, restricted, denied renewal, or voluntarily or involuntarily relinquished',nil,nil],
			['Medicare, Medicaid or Other Governmental Program Participation','Have you ever been disciplined, excluded from, debarred, suspended, reprimanded, sanctioned, censured, disqualified or otherwise restricted in regard to participation in the Medicare or Medicaid program, or in regard to other federal or state governmental health care plans or programs?',nil,nil],
			['Other Sanctions or Investigations','Are you currently the subject of an investigation by any hospital, licensing authority, DEA or CDS authorizing entities, education or training program, Medicare or Medicaid program, or any other private, federal or state health program or a defendant in any civil action that is reasonably related to your qualifications, competence, functions, or duties as a medical professional for alleged fraud, an act of violence, child abuse or a sexual offense or sexual misconduct?',nil,nil],
			['Other Sanctions or Investigations','To your knowledge, has information pertaining to you ever been reported to the National Practitioner Data Bank or Healthcare Integrity and Protection Data Bank?',nil,nil],
			['Other Sanctions or Investigations','Have you ever received sanctions from or are you currently the subject of investigation by any regulatory agencies (e.g., CLIA, OSHA, etc.)?',nil,nil],
			['Other Sanctions or Investigations','Have you ever been convicted of, pled guilty to, pled nolo contendere to, sanctioned, reprimanded, restricted, disciplined or resigned in exchange for no investigation or adverse action within the last ten years for sexual harassment or other illegal misconduct?',nil,nil],
			['Other Sanctions or Investigations',' Are you currently being investigated or have you ever been sanctioned, reprimanded, or cautioned by a military hospital, facility, or agency, or voluntarily terminated or resigned while under investigation or in exchange for no investigation by a hospital or healthcare facility of any military agency?',nil,nil],
			['Professional Liability Insurance Information and Claims History','Has your professional liability coverage ever been cancelled, restricted, declined or not renewed by the carrier based on your individual liability history?',nil,nil],
			['Professional Liability Insurance Information and Claims History','Have you ever been assessed a surcharge, or rated in a high-risk class for your specialty, by your professional liability insurance carrier, based on your individual liability history?',nil,nil],
			['Malpractice Claims History',' Have you ever had any professional liability actions (pending, settled, arbitrated, mediated or litigated) within the past 10 years? If yes, provide information for each case under Professional Liability Claims History.',nil,nil],
			['Criminal/Civil History*','Have you ever been convicted of, pled guilty to, or pled nolo contendere to any felony?', nil,nil],
			['Criminal/Civil History*','Have you ever been court-martialed for actions related to your duties as a medical professional?', 'Note: A criminal record will not necessarily be a bar to acceptance. Decisions will be made by each health plan or credentialing organization based upon all the relevant circumstances, including the nature of the crime. ','alert alert-warning'],
			['Criminal/Civil History*','In the past ten years have you been convicted of, pled guilty to, or pled nolo contendere to any misdemeanor (excluding minor traffic violations) or been found liable or responsible for any civil offense that is reasonably related to your qualifications, competence, functions, or duties as a medical professional, or for fraud, an act of violence, child abuse or a sexual offense or sexual misconduct?', nil,nil],
			['Ability To Perform Job','Are you currently engaged in the illegal use of drugs? ("Currently" means sufficiently recent to justify a reasonable belief that the use of drugs may have an ongoing impact on ones ability to practice medicine. It is not limited to the day of, or within a matter of days or weeks before the date of application, rather that it has occurred recently enough to indicate the individual is actively engaged in such conduct. "Illegal use of drugs" refers to drugs whose possession or distribution is unlawful under the Controlled Substances Act, 21 U.S.C. 812.22. It "does not include the use of a drug taken under supervision by a licensed health care professional, or other uses authorized by the controlled Substances Act or other provision of Federal law." The term does include, however, the unlawful use of prescription controlled substances.)',nil,nil],
			['Ability To Perform Job','Do you use any chemical substances that would in any way impair or limit your ability to practice medicine and perform the functions of your job with reasonable skill and safety?',nil,nil],
			['Ability To Perform Job','Do you have any reason to believe that you would pose a risk to the safety or well being of your patients?',nil,nil],
			['Ability To Perform Job','Are you unable to perform the essential functions of a practitioner in your area of practice even with reasonable accommodation?',nil,nil],
		]

		category_questions.each do |question|
			category = DisclosureCategory.find_by_title(question[0])
			if !DisclosureQuestion.exists?(question: question[1],disclosure_category_id: category.id)
				DisclosureQuestion.create(question: question[1], note: question[2], alert_type: question[3],disclosure_category_id: category.id)
			end
		end
	end

	private

	def set_slug
		self.slug = "q#{DisclosureQuestion.count + 1}"
	end
end