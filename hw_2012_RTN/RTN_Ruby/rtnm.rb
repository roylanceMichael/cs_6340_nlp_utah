class Rtnm
	attr_accessor :machine, :init, :final, :rules
	
	def self.factory(filePath)
		rawFile = File.new(filePath)
		content = rawFile.read
		propertyRegex = /\s*MACHINE\s+([a-zA-Z0-9]+)\s+INIT\s+([a-zA-Z0-9]+)\s+FINAL\s+([a-zA-Z0-9]+)\s+BEGIN([A-Za-z0-9\s]*?)END\s*?/
		result = content =~ propertyRegex

		returnRtnm = Rtnm.new
		returnRtnm.machine = $1
		returnRtnm.init = $2
		returnRtnm.final = $3
		puts "1: #{$1}"
		puts "2: #{$2}"
		puts "3: #{$3}"
		puts "4:#{$4}"
		
		#bIndex = content =~ /\s+BEGIN\s+/
		#eIndex = content =~ /\s+END\s*/
		#bOffset = bIndex + 5
		#processRules = content.slice(bOffset, eIndex - bOffset)
		#puts processRules
		returnRtnm
	end
end