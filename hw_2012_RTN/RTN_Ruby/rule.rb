class Rule
	attr_accessor :start, :arcname, :end, :arctype, :arcref, :parentmachine
	
	def ar(sm, dict, index)
  		#get current word
  		#puts "#{@start} - #{@arcname} (#{sm.windex index}) -> #{@end} #{@arctype == 'machine' && @arcref != nil} (WHY IS THIS FAILING)"
  		if @arctype == "machine" && @arcref != nil
  			res = @arcref.as sm, dict, index
  			if res.length > 0
  				#puts "#{@start} - #{@arcname} (#{sm.windex index}) -> #{@end}"
  				return res
  			end
  		elsif @arctype == "word"
  			current = sm.windex index
  			if dict.any?{|t| t.word == current && t.pos == @arcname}
  				#puts "#{@start} - #{@arcname} (#{sm.windex index}) -> #{@end}"
  				#rt = RuleTuple.new
  				#rt.rule = self
  				#rt.index = index
  				return true
  			end
  		end
  		return []
  end
	
	def self.factory(rawString, machine)
		#expecting to have \r\n delimiters
		propertyRegex = /([A-Za-z0-9]+)\s([A-Za-z0-9]+)\s([A-Za-z0-9]+)/
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