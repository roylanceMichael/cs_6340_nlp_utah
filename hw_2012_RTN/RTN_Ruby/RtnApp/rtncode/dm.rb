class Dm
	attr_accessor :word, :pos
	def setProperties(line)
		line =~ /^\s*(\w+)\s+(\w+)\s*$/
		@word = $1
		@pos = $2
		true
	end
	
	def self.sfactory(content)
    splitContent = content.split /\n/
    dictModels = []
    splitContent.each do |c|
      tempDict = Dm.new
      tempDict.setProperties c
      if tempDict.word != nil && tempDict.pos != nil
        dictModels.push tempDict
      end
    end
    dictModels
  end
	
	def self.factory(fileName)
		dictFile = File.new(fileName)
		dictModels = []
		while line = dictFile.gets
			tempDict = Dm.new
			tempDict.setProperties line 
			dictModels.push tempDict
		end
		dictModels
	end
end