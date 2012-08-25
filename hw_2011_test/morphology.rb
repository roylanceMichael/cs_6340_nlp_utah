#startup
if ARGV != nil && ARGV.length > 3
  bootstrapper(ARGV[0], ARGV[1], ARGV[2])
end

def bootstrapper(dictFile, ruleFile, morphFile)
  @dictModels = DictItemModel.dictFactory(dictFile)
  @ruleModels = RuleItemModel.rulesFactory(ruleFile)
  @morphModels = MorphedItemModel.morphFactory(morphFile, @dictModels, @ruleModels)
end

class MorphedItemModel
  attr_accessor :finalWord, :originalWord
  
  def initialize(originalWord, dictModels, ruleModels)
    @originalWord = originalWord
  end
  
  def self.morphFactory(fileName, dictModels, ruleModels)
    morphFile = File.new(fileName)
    morphModels = []
    while(line = morphFile.gets)
      temp = MorphedItemModel.new(line, dictModels, ruleModels)
      morphModels.push(temp)
    end
    morphModels
  end
end

class DictItemModel
  attr_accessor :word, :type, :root
  
  def setProperties(line)
    line =~ /^\s*(\w+)\s+(\w+)\s*$|^\s*(\w+)\s+(\w+)\s+ROOT\s+(\w+)\s*$/
    #reset
    @word = nil
    @type = nil
    @root = nil
    if $1 != nil && $2 != nil
      @word = $1
      @type = $2
    elsif $3 != nil && $4 != nil && $5 != nil
      @word = $3
      @type = $4
      @root = $5
    end
    true
  end
  
  def self.dictFactory(fileName)
    dictFile = File.new(fileName)
    dictModels = []
    while(line = dictFile.gets)
      tempDict = DictItemModel.new
      tempDict.setProperties(line)
      dictModels.push(tempDict)
    end
    dictModels
  end
end

class RuleItemModel
  attr_accessor :type, :beReplace, :replaceWith, :posPre, :posPost
  
  def setProperties(line)
    line =~ /^\s*(SUFFIX|PREFIX)\s+([A-Za-z]+)\s+([A-Za-z-]+)\s+([A-Za-z]+)\s+->\s+([A-Za-z]+)\s*\.$/
    @type = $1
    @beReplace = $2
    @replaceWith = $3
    @posPre = $4
    @posPost = $5
  end
  
  def self.rulesFactory(fileName)
    ruleFile = File.new(fileName)
    ruleModels = []
    while(line = ruleFile.gets)
      tempRule = RuleItemModel.new
      tempRule.setProperties(line)
      ruleModels.push(tempRule)
    end
    ruleModels
  end
end
