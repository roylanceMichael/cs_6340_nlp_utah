class Rule
	attr_accessor :start, :arcname, :end, :arctype, :arcref, :parentmachine, :sm
	
	def applyRule(dict)
		puts "applyRule:(#{@sm.word}), #{@start} -> #{@arcname} -> #{@arctype} -> #{@end}"
		if @arctype == "word"
			if dict.any? {|t| t.word == @sm.word && t.pos == @arcname}
				puts "#{@start} - #{@arcname} (#{@sm.word}) -> #{@end}"
				@sm.index = @sm.index + 1
				return [self, @sm]
			end
		elsif @arctype == "machine"	&& @arcref != nil
			result = @arcref.applySentence @sm, dict
			if result != nil && result.length > 0
				puts "#{@start} - #{@arcname} -> #{@end}"
				return result
			end
		end
		
		return nil
	end
	
	def self.factory(rawString, machine)
		#expecting to have \r\n delimiters
		propertyRegex = /^([A-Za-z0-9]+)\s([A-Za-z0-9]+)\s([A-Za-z0-9]+)$/
		rules = []
		match = propertyRegex.match(rawString)
		
		while match != nil		
			rule = Rule.new
			rule.start = match[1]
			rule.arcname = match[2]
			rule.end = match[3]
			rule.parentmachine = machine
			rules.push rule
			match = propertyRegex.match(match.post_match)
		end
		rules
	end
end