#startup
if ARGV != nil && ARGV.length > 3
  bootstrapper(ARGV[0], ARGV[1], ARGV[2])
end

def bootstrapper(dictFile, ruleFile, morphFile)
  @dictModels = DictItemModel.dictFactory(dictFile)
  @ruleModels = RuleItemModel.rulesFactory(ruleFile)
  #@morphModels = MorphedItemModel.morphFactory
end

class MorphologyTests
  attr_accessor :dictModels, :ruleModels
  
  def runAll(dictFile, ruleFile)
    if(dictFile == nil || ruleFile == nil)
      puts "must have dictFile or ruleFile!"
      return
    end
    
    @dictModels = DictItemModel.dictFactory(dictFile)
    @ruleModels = RuleItemModel.rulesFactory(ruleFile)
    
    allTests = self.methods.select{|t| (t.to_s =~ /Test/) != nil}
    allTests.each do |test| 
      puts "executing #{test}, result is #{self.send test}"
    end
  end
  
  def dictTest
    #arrange
    #act
    morph = morphologicalAnalyzer("be", @dictModels, @ruleModels).first
    #assert
    puts "#{morph.finalWord} - #{morph.type} - #{morph.foundMethod} - #{morph.originalWord}"
    return morph.finalWord == "be" && morph.type == "verb" && morph.foundMethod == "dictionary" && morph.originalWord == "be"
  end
  
  def dictRootTest
    #arrange
    #act
    morph = morphologicalAnalyzer("slept", @dictModels, @ruleModels).first
    #assert
    return morph.finalWord == "sleep" && morph.type == "verb" && morph.foundMethod == "dictionary" && morph.originalWord == "slept"
  end
  
  def noDictTest
    #arrange
    #act
    morph = morphologicalAnalyzer("utah", @dictModels, @ruleModels).first
    #assert
    return morph.finalWord == "utah" && morph.type == "noun" && morph.foundMethod == "default" && morph.originalWord == "utah"
  end
  
  def morphDictTest
    #arrange
    #act
    morph = morphologicalAnalyzer("hairy", @dictModels, @ruleModels).first
    #assert
    puts "#{morph.finalWord} - #{morph.type} - #{morph.foundMethod} - #{morph.originalWord}"
    return morph.finalWord == "hair" && morph.type == "adjective" && morph.foundMethod == "morphology" && morph.originalWord == "hairy"
  end
  
  def anticeilingTest
    #arrange
    #act
    morph = morphologicalAnalyzer("anticeiling", @dictModels, @ruleModels).first
    #assert
    return morph.finalWord == "ceiling" && morph.type == "adjective" && morph.foundMethod == "morphology" && morph.originalWord == "anticeiling"
  end

  def storesTest
    #arrange
    #act
    morph = morphologicalAnalyzer("stores", @dictModels, @ruleModels).first
    #assert
    return morph.finalWord == "store" && morph.type == "verb" && morph.foundMethod == "morphology" && morph.originalWord == "stores"
  end
end

def returnDictItems(word, dictModels)
  morphedItemsInDict = []
  dictModels.select{|t| t.word == word}.each do |dictItem|
    temp = MorphedItemModel.new
    temp.originalWord = word
    if dictItem.root != nil
      temp.finalWord = dictItem.root
    else
      temp.finalWord = dictItem.word
    end
    temp.foundMethod = "dictionary"
    temp.type = dictItem.type
    morphedItemsInDict.push temp
  end
  morphedItemsInDict
end

def morphologicalAnalyzer(word, dictModels, ruleModels)
  originalWord = word
  dictItems = returnDictItems(word, dictModels)
  if(dictItems.length > 0)
    return dictItems
  else
    #we need to do the following:
    premorphedWord = MorphedItemModel.new
    premorphedWord.originalWord = originalWord
    premorphedWord.finalWord = originalWord
    puts "starting out with #{originalWord}"
    currentRule = ruleModels.select{|t| t.match(premorphedWord.finalWord)}.first
    if(currentRule != nil)
      while(currentRule != nil)
        premorphedWord.finalWord = currentRule.applyRule(premorphedWord.finalWord)
        currentRule = ruleModels.select{|t| t.match(premorphedWord.finalWord)}.first
      end
      items = returnDictItems(premorphedWord.finalWord, dictModels)
      items.each{|t| t.originalWord = originalWord }
      return items
    else
      #default case
      returnMorph = MorphedItemModel.new
      returnMorph.originalWord = originalWord
      returnMorph.finalWord = originalWord
      returnMorph.foundMethod = "default"
      returnMorph.type = "noun"
      return [].push returnMorph
    end
  end
end

class MorphedItemModel
  attr_accessor :finalWord, :originalWord, :foundMethod, :type
  
  def applyRules(originalWord, dictModels, ruleModels)
    @originalWord = originalWord
    @finalWord = originalWord

    if(!findWordInDictionary(dictModels))

      if(ruleModels != nil)
        currentRule = ruleModels.select{|t| t.match(self)}.first
        #puts "currentRule is #{currentRule == nil}"
        if(currentRule != nil)
          while(currentRule != nil)  
            #puts "changing #{@finalWord}, #{@type}"
            currentRule.applyRule(self)
            #puts "changed #{@finalWord}, #{@type}"
            currentRule = ruleModels.select{|t| t.match(self)}.first
          end
        else
          @finalWord = originalWord
          @type = "noun"
          @foundMethod = "default"
        end
      end
    end
  end
  
  def findWordInDictionary(dictModels)
    #First, look up the word in the dictionary
    foundWords = dictModels.select {|t| t.word == @originalWord }
    puts "found #{foundWords.length} in the dictionary for #{@originalWord}"
    if(foundWords.length > 0)
      if(foundWords[0].root != nil)
        @finalWord = foundWords[0].root
      else
        @finalWord = foundWords[0].word
      end
      @foundMethod = "dictionary"
      @type = foundWords[0].type
      return true
    end
    return false
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
    @beReplace = @type == "SUFFIX" ? Regexp.new("#{$2}$") : Regexp.new("^#{$2}")
    @replaceWith = $3 != "-" ? $3 : ""
    @posPre = $4
    @posPost = $5
  end
  
  def match(word)
    return (word =~ @beReplace) != nil
  end
  
  def applyRule(word)
   return word.gsub(@beReplace, @replaceWith)
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