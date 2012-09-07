require './rule.rb'
class Rtnm
	attr_accessor :machine, :init, :final, :rules
	
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
			rtnm.machine = match[1]
			rtnm.init = match[2]
			rtnm.final = match[3].strip.split(/\s/)
			rtnm.rules = Rule.factory(match[4])
			
			machines.push rtnm
			match = propertyRegex.match(match.post_match)
		end
		machines
	end
end