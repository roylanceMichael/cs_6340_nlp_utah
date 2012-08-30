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
    #puts "#{morph.originalWord} #{morph.finalWord} #{morph.foundMethod} #{morph.type}"
    return morph.finalWord == "be" && morph.type == "verb" && morph.foundMethod == "dictionary" && morph.originalWord == "be"
  end
  
  def dictRootTest
    #arrange
    #act
    morph = morphologicalAnalyzer("slept", @dictModels, @ruleModels).first
    #assert
    #puts "#{morph.originalWord} #{morph.finalWord} #{morph.foundMethod} #{morph.type}"
    return morph.finalWord == "sleep" && morph.type == "verb" && morph.foundMethod == "dictionary" && morph.originalWord == "slept"
  end
  
  def noDictTest
    #arrange
    #act
    morph = morphologicalAnalyzer("utah", @dictModels, @ruleModels).first
    #assert
    #puts "#{morph.originalWord} #{morph.finalWord} #{morph.foundMethod} #{morph.type}"
    return morph.finalWord == "utah" && morph.type == "noun" && morph.foundMethod == "default" && morph.originalWord == "utah"
  end
  
  def morphDictTest
    #arrange
    #act
    morph = morphologicalAnalyzer("hairy", @dictModels, @ruleModels).first
    #assert
    #puts "#{morph.originalWord} #{morph.finalWord} #{morph.foundMethod} #{morph.type}"
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
    morph = morphologicalAnalyzer("stores", @dictModels, @ruleModels)
    #assert
    morph.each do |morphed|
      #puts "#{morphed.originalWord} #{morphed.finalWord} #{morphed.foundMethod} #{morphed.type}"
    end
    morph.any?{|t| t.finalWord == "store" && t.type == "verb" && t.foundMethod == "morphology" && t.originalWord == "stores" } &&
      morph.any?{|t| t.finalWord == "store" && t.type == "noun" && t.foundMethod == "morphology" && t.originalWord == "stores" }
  end
  
  def sleepedTest
    #arrange
    #act
    morph = morphologicalAnalyzer("sleeped", @dictModels, @ruleModels)
    #assert
    morph.each do |morphed|
      #puts "#{morphed.originalWord} #{morphed.finalWord} #{morphed.foundMethod} #{morphed.type}"
    end
    morph.any?{|t| t.finalWord == "sleep" && t.type == "verb" && t.foundMethod == "morphology" && t.originalWord == "sleeped" } &&
      morph.any?{|t| t.finalWord == "sleep" && t.type == "adjective" && t.foundMethod == "morphology" && t.originalWord == "sleeped" }
  end
  
  def sleepiestTest
    #arrange
    #act
    morph = morphologicalAnalyzer("sleepiest", @dictModels, @ruleModels)
    #assert
    morph.each do |morphed|
      puts "#{morphed.originalWord} #{morphed.finalWord} #{morphed.foundMethod} #{morphed.type}"
    end
    morph.any?{|t| t.finalWord == "sleep" && t.type == "adjective" && t.foundMethod == "morphology" && t.originalWord == "sleepiest" }
  end
  
  def reviewsTest
    #arrange
    #act
    morph = morphologicalAnalyzer("reviews", @dictModels, @ruleModels)
    #assert
    morph.each do |morphed|
      puts "#{morphed.originalWord} #{morphed.finalWord} #{morphed.foundMethod} #{morphed.type}"
    end
    morph.any?{|t| t.finalWord == "view" && t.type == "verb" && t.foundMethod == "morphology" && t.originalWord == "reviews" }
  end
  
  def reviewedTest
    #arrange
    #act
    morph = morphologicalAnalyzer("rereviewed", @dictModels, @ruleModels)
    #assert
    morph.each do |morphed|
      puts "#{morphed.originalWord} #{morphed.finalWord} #{morphed.foundMethod} #{morphed.type}"
    end
    morph.any?{|t| t.finalWord == "view" && t.type == "verb" && t.foundMethod == "morphology" && t.originalWord == "rereviewed" } && false
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

def recursivelyFind(originalWord, foundRules)
    
    if(foundRules.length == 0)
      return []
    end
    
    #puts "originalWord is #{originalWord}"
    #puts "foundRules.length is #{foundRules.length}"
    
    morphedItems = []
    foundRules.each do |rule|
      tempWord = MorphedItemModel.new
      tempWord.originalWord = originalWord
      tempWord.finalWord = originalWord
      rule.applyRule(tempWord)
      morphedItems.push tempWord
    end
    
    foundRules = []
    keepWords = []
    
    #puts "morphedItems.length #{morphedItems.length}"
    
    morphedItems.each do |word|
      #puts "#{word.finalWord} - #{word.originalWord} - #{word.preType} #{word.type}"
      if dictModels.any?{|dict| dict.word == word.finalWord && dict.type == word.preType}
        #puts "#{word.finalWord} - #{word.originalWord} - #{word.preType} #{word.type}"
        keepWords.push word
      end
    end
    if keepWords.length > 0
      #puts "got here first round"
      #puts "keepWords.length is #{keepWords.length}"
      return keepWords
    else  
      morphedItems.each do |word|
        #also populate new foundRules
        newRules = ruleModels.select{|t| t.match(word.finalWord, word.type)}
        if newRules.length > 0
          #puts "--------- #{newRules.length} --------------"
          newRules.each do |rule|
            #puts "new found rules #{rule.type} - #{rule.toBeReplaced} - #{rule.replaceWith} - #{rule.posPre} - #{rule.posPost}"
          end
        
          #puts "now trying #{word.finalWord} with previous rules"
          t = recursivelyFind(word.finalWord, newRules)
          #puts "result of #{word.finalWord} is #{t.length}"
          return t
        end
      end
    end
end

def morphologicalAnalyzer(word, dictModels, ruleModels)
  originalWord = word
  dictItems = returnDictItems(word, dictModels)
  if(dictItems.length > 0)
    return dictItems
  else
    #puts "starting out with #{originalWord}"
    foundRules = ruleModels.select{|t| t.match(originalWord, nil)}
    if(foundRules.length > 0)
      t = recursivelyFind(originalWord, foundRules)
      t.each {|f| f.originalWord = word }
      return t
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
  attr_accessor :finalWord, :originalWord, :foundMethod, :type, :preType
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
  attr_accessor :type, :toBeReplaced, :replaceWith, :posPre, :posPost
  
  def setProperties(line)
    line =~ /^\s*(SUFFIX|PREFIX)\s+([A-Za-z]+)\s+([A-Za-z-]+)\s+([A-Za-z]+)\s+->\s+([A-Za-z]+)\s*\.$/
    @type = $1
    @toBeReplaced = @type == "SUFFIX" ? Regexp.new("#{$2}$") : Regexp.new("^#{$2}")
    @replaceWith = $3 != "-" ? $3 : ""
    @posPre = $4
    @posPost = $5
  end
  
  def match(word, posPost)
    result = ((word =~ @toBeReplaced) != nil) && (posPost == nil || posPost == @posPre)
    #puts "word: #{word}, #{word =~ @toBeReplaced}, posPre: #{posPost} -- compared with #{@toBeReplaced} #{@posPre}... result: #{result}, #{posPost} #{@posPre}"
    return result
  end
  
  def applyRule(word)
   word.finalWord = word.finalWord.gsub(@toBeReplaced, @replaceWith)
   #puts "#{@posPost}"
   word.foundMethod = "morphology"
   word.type = @posPost
   word.preType = @posPre
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