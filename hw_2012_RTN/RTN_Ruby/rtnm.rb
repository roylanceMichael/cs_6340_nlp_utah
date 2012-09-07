class Rtnm
	attr_accessor :machine, :init, :final, :rules
	
	def self.factory(filePath)
		rawFile = File.new(filePath)
		content = rawFile.read
		propertyRegex = /MACHINE\s+([a-zA-Z0-9]+?)\s+INIT\s+([a-zA-Z0-9]+?)\s+FINAL\s+([a-zA-Z0-9\s]+?)\s+BEGIN([A-Za-z0-9\s]+?)END\s*/
		match = propertyRegex.match(content)
		machines = []
		while(match != nil)
			postMatch = match.post_match.strip
			
			#puts "match: #{match}"
			#puts "post match: #{postMatch}"
			
			returnRtnm = Rtnm.new
			returnRtnm.machine = match[1]
			returnRtnm.init = match[2]
			returnRtnm.final = match[3].strip.split(/\s/)
			
			machines.push returnRtnm
			match = propertyRegex.match(postMatch)
		end
		machines
	end
end