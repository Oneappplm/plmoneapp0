class String
	def to_role
		self.downcase.gsub(' ', '_')
	end
end