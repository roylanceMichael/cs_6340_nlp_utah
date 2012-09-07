class Dm
	attr_accessor :word, :pos
	def setProperties(line)
		line =~ /^\s*(\w+)\s+(\w+)\s*$/
		@word = $1
		@pos = $2
		true
	end
	
	def self.factory(fileName)
		dictFile = File.new(fileName)
		dictModels = []
		while(line = dictFile.gets)
			tempDict = Dm.new
			tempDict.setProperties(line)
			dictModels.push(tempDict)
		end
		dictModels
	end
end