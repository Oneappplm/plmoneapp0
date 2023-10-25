class String
	def to_param
		return self	unless self.present?

		self.downcase.parameterize(separator: '_')
	end
end
