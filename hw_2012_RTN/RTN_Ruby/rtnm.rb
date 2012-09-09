require './rule.rb'
class Rtnm
	attr_accessor :machinename, :init, :final, :rules
	
	def applySentence(sm, dict)
		#we are assuming we're at the beginning now
		#we're also assuming there's one path
		
		if sm.word == nil
			puts "nil word!"
			return nil
		end
		
		rulesToTry = rules.select{|t| t.start == @init}.each{|t| t.sm = sm.copy}
		
		successfulRules = []
		
		while rulesToTry.length > 0
			currentRule = rulesToTry.delete_at 0
			
			if currentRule.sm.word == nil
				next
			end
			
			puts "applySentence:(#{currentRule.sm.word})(#{currentRule.sm}) @ #{@machinename}, rule: #{currentRule.start} - #{currentRule.arcname} - #{currentRule.end}"
			
			#pretty sure I need to do more here...
			result = currentRule.applyRule dict
			if result != nil
				if final.any? {|t| t == currentRule.end}
					puts "(SUCCESSFUL RULE) (#{currentRule.sm}) #{currentRule.start} - #{currentRule.arcname} - #{currentRule.end} - index(#{currentRule.sm.index})"
					currentRule.sm = currentRule.sm.copy
					successfulRules.push currentRule
				end
				#add more rules, if we can
				moreRules = rules.select{|t| t.start == currentRule.end}
				
				moreRules.each do |t|
					t.sm = currentRule.sm.copy
					rulesToTry.push t
				end
			end
		end
		
		puts "ended #{@machinename} with #{successfulRules.length} rules"
		
		successfulRules.each do |rule|
			puts "#{rule.sm} #{rule.start} - #{rule.arcname} - #{rule.end} - #{rule.sm.sentence} - index(#{rule.sm.index})"
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