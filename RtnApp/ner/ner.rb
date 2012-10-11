if ARGV != nil && ARGV.length > 3
  seedsStr = (File.new ARGV[0]).read
  trainingStr = (File.new ARGV[1]).read
  testStr = (File.new ARGV[2]).read
  
  initialRules = Rule.factory seedsStr
  trInstances = Instance.factory trainingStr
  test = Instance.factory testStr
end

# ideas for class...
# come up with initial 

class Ner
  attr_accessor :rules, :trainingInst, :testInst, :initRules, :freqLimit, :probLimit
  
  def initialize(initRules, trainingInst, testInst)
    @probLimit = 0.8
    @freqLimit = 5
    @rules = []
    
    initRules.each do |initRule|
      initRule.prob = -1.to_f
      initRule.freq = -1
    end
    
    @initRules = initRules.sort{|a, b| [b.prob, b.freq, a.contains] <=> [a.prob, a.freq, b.contains]}
    @trainingInst = trainingInst
    @testInst = testInst
  end
    
  def printRules
    returnLog = ""
    @rules.each do |rule|
      returnLog = "#{returnLog}\n#{rule.printSelf}"
    end
    returnLog
  end
  
  def resetRules
    @rules = []
    @initRules.each do |rule|
      r = Rule.new
      r.type = rule.type
      r.contains = rule.contains
      r.tclass = rule.tclass
      @rules.push r
    end
  end
  
  def execute
    reset
    returnLog = "SEED DECISION LIST"
    returnLog = returnLog + "\n#{printRules}"
    returnLog = returnLog + "\nITERATION #1 NEW CONTEXT RULES"
    
    puts returnLog
    
    ctxResult = contextIteration
    first = updateCtxTraining ctxResult
    puts first
    returnLog = "#{returnLog}\n#{first}"
    
    returnLog = "#{returnLog}\nITERATION #1 NEW NP RULES"
    npResult = npIteration
    second = updateNpTraining npResult
    puts second
    returnLog = "#{returnLog}\n#{second}"
    
    returnLog = "#{returnLog}\nITERATION #2 NEW CONTEXT RULES"
    
    puts returnLog
    
    ctxResult = contextIteration
    third = updateCtxTraining ctxResult
    returnLog = "#{returnLog}\n#{third}"
    
    puts third
    
    returnLog = "#{returnLog}\nITERATION #2 NEW NP RULES"
    
    npResult = npIteration
    fourth = updateNpTraining npResult
    returnLog = "#{returnLog}\n#{fourth}"
    
    puts fourth
    
    returnLog = "#{returnLog}\nITERATION #3 NEW CONTEXT RULES"
    
    ctxResult = contextIteration
    fifth = updateCtxTraining ctxResult
    returnLog = "#{returnLog}\n#{fifth}"
    
    puts fifth
    
    returnLog = "#{returnLog}\nITERATION #3 NEW NP RULES"
    
    puts returnLog
    
    npResult = npIteration
    sixth = updateNpTraining npResult
    returnLog = "#{returnLog}\n#{sixth}"
    
    puts sixth
    
    returnLog = "#{returnLog}\nFINAL DECISION LIST"
    
    seventh = printRules
    returnLog = "#{returnLog}\n#{seventh}"
  end
  
  def reset
    @trainingInst.each do |train|
      train.tclass = nil
    end
    
    resetRules
    
    setInitialSeeds
  end
  
  def allTclasses
    tclasses = []
    @rules.each do |rule|
      if !(tclasses.any? {|t| t == rule.tclass})
        tclasses.push rule.tclass
      end
    end
    tclasses.sort{|a, b| a <=> b}
  end
  
  #handle NP Iteration
  def contextIteration
    ctxIterResults = []
    
    nilClassTrain = @trainingInst.select{|t| t.tclass != nil}
    
    contextWords.each do |word|
      count = 0
      ctxHash = { }
      
      nilClassTrain.each do |train|
        
        train.contextSplit.each do |ctx|
          #puts "comparing #{ctx} vs #{word}..."
          if ctx == word
            #puts "#{train.printSelf}"
            count = count + 1
            
            if ctxHash.has_key? train.tclass
              ctxHash[train.tclass] = ctxHash[train.tclass] + 1
            else
              ctxHash[train.tclass] = 1
            end
            break
          end
        end
      end
      
      if count >= @freqLimit
        #puts "found #{count} of '#{word}'"
        ctxHash["count"] = count
        ctxHash["word"] = word
        ctxIterResults.push ctxHash
      end
    end
    ctxIterResults
  end
  
  def npIteration
    npIterResults = []
    
    nilClassTrain = @trainingInst.select{|t| t.tclass != nil}
    
    npWords.each do |word|
      count = 0
      npHash = { }
      
      nilClassTrain.each do |train|
        train.npSplit.each do |np|
          #puts "comparing #{np} vs #{word}..."
          if np == word
            #puts "success!"
            count = count + 1
            
            if npHash.has_key? train.tclass
              npHash[train.tclass] = npHash[train.tclass] + 1
            else
              npHash[train.tclass] = 1
            end
          end
        end
      end
      
      if count > @freqLimit
        npHash["count"] = count
        npHash["word"] = word
        npIterResults.push npHash
      end
      #puts "found #{count} of #{word}!"
    end
    npIterResults
  end
  #end NP Iteration
  
  #handle CONTEXT Iteration
  def handleIteration(iterNum)
    returnString = "ITERATION # #{iterNum}: NEW CONTEXT RULES"
    
    result = contextIteration
    sortedBestRules = updateCtxTraining result
    
    r = applyBestRules sortedBestRules
    returnString = "#{returnString}\n#{r}\nITERATION # #{iterNum}: NEW NP RULES"
    
    result = npIteration
    
    sortedBestRules = updateNpTraining result
    
    r = applyBestRules sortedBestRules
    returnString = "#{returnString}\n#{r}"
  end
  
  def applyBestRules(bestRules)
    returnString = ""
    bestRules.each do |rule|
      returnString = "#{returnString}\n#{rule.printSelf}"
      applyRuleToNilInstances rule
      @rules.push rule
    end
    returnString
  end
  
  def updateNpTraining(npIterResults)
    countedIters = []
    returnRules = []
    returnLog = ""
    
    npIterResults.each do |npIter|
      count = npIter["count"]
      word = npIter["word"]
      
      allTclasses.each do |tclass|
        prob = npIter[tclass].to_f / count.to_f
        if npIter.has_key?(tclass) && prob >= @probLimit
          # greater than 80%?
          # update everyone with the same ctx
          
          newRule = Rule.new
          newRule.type = "NP"
          newRule.contains = word
          newRule.tclass = tclass
          newRule.prob = prob
          newRule.freq = count
          
          if !(@rules.any?{|t| t.type == newRule.type && newRule.contains == t.contains})
            returnLog = "#{returnLog}\n#{newRule.printSelf}"
            returnRules.push newRule
          end
        end
      end
    end
    
    puts "WHY OH WHY"
    returnRules.each do |rule|
      rule.putSelf
    end
    
    bestRules(returnRules)
  end
    
  def updateCtxTraining(ctxIterResults)
    countedIters = []
    returnRules = []
    returnLog = ""
    #each iteration
    ctxIterResults.each do |ctxIter|
      count = ctxIter["count"]
      word = ctxIter["word"]
      
      allTclasses.each do |tclass|
        prob = ctxIter[tclass].to_f / count.to_f
        if ctxIter.has_key?(tclass) && prob >= @probLimit
          # greater than 80%?
          # update everyone with the same ctx
          newRule = Rule.new
          newRule.type = "CONTEXT"
          newRule.contains = word
          newRule.tclass = tclass
          newRule.prob = prob
          newRule.freq = count
          
          if !(@rules.any?{|t| t.type == newRule.type && newRule.contains == t.contains})
            returnLog = "#{returnLog}\n#{newRule.printSelf}"
            returnRules.push newRule
          end
        end
      end
    end
    
    bestRules(returnRules)
  end
  #end CONTEXT Iteration
  
  def sortDef(givenRules)
    r = givenRules.sort do |a, b| 
      if a.prob != b.prob
        b.prob <=> a.prob
      elsif a.freq != b.freq
        b.freq <=> a.freq
      else
        a.contains <=> b.contains
      end
    end
    r
  end
  
  def sortRules(givenRules, tclass)
    r = sortDef(givenRules.select{|t| t.tclass == tclass})
    puts "WHATS THE STORY MORNING GLORY -> #{tclass}"
    r.each do |rule|
      #rule.putSelf
    end
    r
  end
  
  def bestRules(givenRules)
    best = []
    allTclasses.each do |tclass|
      count = 0
      
      r = sortRules(givenRules, tclass)
      
      r.each do |rule|

        if count < 2
          best.push rule
          count = count + 1
        else
          break
        end
      
      end
    end
    sortDef(best)
  end
  
  def contextWords
    contextRules = []
    trainingInst.each do |inst|
      inst.contextSplit.each do |ctx|
        if !(contextRules.select{|t| t == ctx}.any?)
          contextRules.push ctx
        end
      end
    end
    contextRules
  end
  
  def npWords
    npRules = []
    trainingInst.each do |inst|
      inst.npSplit.each do |np|
        if !(npRules.select{|t| t == np}.any?)
          npRules.push np
        end
      end
    end
    npRules
  end
  
  def setInitialSeeds
    @rules.select{|t| t.type == "NP"}.each do |rule|
      rule.prob = -1
      rule.freq = -1
      #puts "Contains: #{rule.contains}"
      applyRuleToNilInstances rule
    end
  end
  
  def applyRuleToNilInstances(rule)
    @trainingInst.select{|t| t.tclass == nil}.each do |instance|
      if rule.type == "NP"
        instance.npSplit.each do |word|
          if word == rule.contains
            puts "Instance #{instance.printSelf} to #{rule.printSelf}"
            instance.tclass = rule.tclass
          end
        end
      else
        instance.contextSplit.each do |word|
          if word == rule.contains
            puts "Instance #{instance.printSelf} to #{rule.printSelf}"
            instance.tclass = rule.tclass
          end
        end
      end
    end
  end
end