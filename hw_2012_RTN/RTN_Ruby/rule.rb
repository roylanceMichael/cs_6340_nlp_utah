class Rule
	attr_accessor :start, :arcname, :end, :arctype, :arcref, :parentmachine
	
	def ar(sm, dict, index, rtnm)
  		if @arctype == "machine"
  		  foundMachine = rtnm.select{|t| t.machinename == @arcname }
  		  if foundMachine != nil && foundMachine.length > 0
  			  res = foundMachine.first.as sm, dict, index, rtnm
  			  if res.length > 0
  				  return res
  			  end
			  end
  		elsif @arctype == "word"
  			current = sm.windex index
  			if current != nil && dict.any?{|t| t.word.downcase == current.downcase && t.pos.downcase == @arcname.downcase}
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