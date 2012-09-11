require './rule.rb'
class Rtnm
	attr_accessor :machinename, :init, :final, :rules
	
	#sm is used to access the sentence
	#dict is a static dictionary
	#chart is used to keep a history of what we've tried
	#altpaths is used to keep track of alternate paths
	def as(sm, dict, index)
		#start at beginning
		puts "processing #{@machinename} at #{sm.windex index}"
		#get all start states for current machine
		rulesToTry = []
		@rules.select{|t| t.start == @init}.each do |r|
			tr = RuleTuple.new
			tr.rule = r
			tr.index = index
			rulesToTry.push tr
		end
		
		success = []
		
		puts "found #{rulesToTry.length} rules to try"
		
		while rulesToTry.length > 0
			cr = rulesToTry.delete_at 0
			
			result = cr.rule.ar sm, dict, cr.index
			puts "(#{sm.windex cr.index})#{cr.rule.start} - #{cr.rule.arcname} - #{cr.rule.end} was #{result == nil ? 'failure' : result}"
			
			#number if the rule was successful
			#what to return if multiple rules were successful?
			if result != nil
				
				#this is potentially good to go
				if final.any? {|t| t == cr.rule.end}
					result.each do |r|
						puts "pushing #{r.printself} because #{cr.rule.end} is an end state"
						success.push r
					end
				end
				@rules.select{|t| t.start == cr.rule.end}.each do |rule|
					result.each do |r|
						tr = RuleTuple.new
						tr.rule = rule
						tr.index = r.index
						tr.prev = cr
						rulesToTry.push tr
					end
				end
			end
		end
		success
	end
	
	def applySentence(sm, dict)
		#we are assuming we're at the beginning now
		#we're also assuming there's one path
		
		if sm.word == nil
			return nil
		end
		
		rulesToTry = rules.select{|t| t.start == @init}.each{|t| t.sm = sm.copy}
		
		successfulRules = []
		
		while rulesToTry.length > 0
			currentRule = rulesToTry.delete_at 0
			
			if currentRule.sm.word == nil
				next
			end
			
			#pretty sure I need to do more here...
			result = currentRule.applyRule sm, dict
			
			if result != nil
				if final.any? {|t| t == currentRule.end}
					puts result.length
					result.each {|sentenceModel| successfulRules.push sentenceModel}
				end
				#add more rules, if we can
				result.each do |sentenceModel|
					moreRules = rules.select{|t| t.start == currentRule.end}
					
					moreRules.each do |rule|
						newRule = rule.copy
						newRule.sm = sm.copy
						rulesToTry.push newRule
					end
				end
			end
		end
		
		puts "ended #{@machinename} with #{successfulRules.length} rules"
		successfulRules.each do |anotherSm|
			puts "       "
			puts "-------"
			puts anotherSm
			anotherSm.printhistory
			puts "-------"
			puts "       "
		end
		
		successfulRules
	end
	
	def self.factory(filePath)
		rawFile = File.new(filePath)
		content = rawFile.read
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
end