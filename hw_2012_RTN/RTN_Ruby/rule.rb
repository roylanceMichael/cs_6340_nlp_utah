class Rule
	attr_accessor :start, :arc, :end
	
	def self.factory(rawString)
		#expecting to have \r\n delimiters
		propertyRegex = /^([A-Za-z0-9]+)\s([A-Za-z0-9]+)\s([A-Za-z0-9]+)$/
		rules = []
		match = propertyRegex.match(rawString)
		
		while match != nil		
			rule = Rule.new
			rule.start = match[1]
			rule.arc = match[2]
			rule.end = match[3]
			rules.push rule
			match = propertyRegex.match(match.post_match)
		end
		rules
	end
end