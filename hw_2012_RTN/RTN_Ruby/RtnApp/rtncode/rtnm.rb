class Rtnm
	attr_accessor :machinename, :init, :final, :rules

	def as(sm, dict, index, rtnm)
		rulesToTry = []
		@rules.select{|t| t.start == @init}.each do |r|
			tr = RuleTuple.new
			tr.rule = r
			tr.index = index
			rulesToTry.push tr
		end

		success = []
		while rulesToTry.length > 0
			cr = rulesToTry.delete_at 0
			word = sm.windex cr.index
			if word == nil
				next
			end

			result = cr.rule.ar sm, dict, cr.index, rtnm
			
			if result.class == TrueClass
			  #puts "#{cr.rule.start} - #{cr.rule.arcname} -> #{cr.rule.end}"
				newCr = RuleTuple.new
				newCr.rule = cr.rule
				newCr.index = cr.index
				newCr.prev = cr.prev
				if final.any? {|t| t == cr.rule.end}
					tr = newCr.copy
					tr.accept = "#{cr.rule.end}(ACCEPT)"
					success.push tr
				end
				@rules.select{|t| t.start == cr.rule.end}.each do |rule|
  					tr = RuleTuple.new
  					tr.rule = rule
  					tr.index = newCr.index + 1
  					tr.prev = newCr
  					rulesToTry.push tr.copy
  			end
  		elsif result.length > 0
  		    #puts "#{cr.rule.start} - #{cr.rule.arcname} -> #{cr.rule.end}"
  				result.each do |nrnh|
  				  nrc = nrnh.copy
					  newCr = cr.copy
  					nrc.root.prev = newCr
           
  					if final.any? {|t| t == cr.rule.end}
  					  tr = nrc.copy
  					  tr.accept = "#{cr.rule.end}(ACCEPT)"
  						success.push tr
  					end
  					@rules.select{|t| t.start == cr.rule.end}.each do |rule|
  						tr = RuleTuple.new
  						tr.rule = rule
  						tr.index = nrnh.index + 1
  						tr.prev = nrc
  						rulesToTry.push tr
  					end
  				end
  			end
  		end
  		success
  	end
  
  def self.flogic(content)
    propertyRegex = /MACHINE\s+([a-zA-Z0-9]+?)\s+INIT\s+([a-zA-Z0-9]+?)\s+FINAL\s+([a-zA-Z0-9\s]+?)\s+BEGIN([A-Za-z0-9\s]+?)END\s*/
		machines = []
		
		match = propertyRegex.match(content)
		while(match != nil)
			#puts "match: #{match}"
			#puts "post match: #{match.post_match}"
			
			rtnm = Rtnm.new
			rtnm.machinename = match[1]
			rtnm.init = match[2]
			rtnm.final = match[3].strip.split(/\s/)
			rtnm.rules = Rule.factory match[4], rtnm
			
			machines.push rtnm
			match = propertyRegex.match match.post_match
		end
		machines
  end
	
	def self.factory(filePath)
		rawFile = File.new(filePath)
		content = rawFile.read
    result = flogic content
    result
	end
end