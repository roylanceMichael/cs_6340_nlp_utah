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
  attr_accessor :rules, :trainingInst, :testInst, :initRules
  
  def initialize(initRules, trainingInst, testInst)
    @rules = []
    @initRules = initRules
    @trainingInst = trainingInst
    @testInst = testInst
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
    puts "SEED DECISION LIST"
    @rules.each do |rule|
      puts "#{rule.type} CONTAINS(#{rule.contains}) -> #{rule.tclass}"
    end
    
    puts "ITERATION #1 NEW CONTEXT RULES"
    
    ctxResult = contextIteration
    updateCtxTraining ctxResult
    
    puts "ITERATION #1 NEW NP RULES"
    
    npResult = npIteration
    updateNpTraining npResult
    
    puts "ITERATION #2 NEW CONTEXT RULES"
    
    ctxResult = contextIteration
    updateCtxTraining ctxResult
    
    puts "ITERATION #2 NEW NP RULES"
    
    npResult = npIteration
    updateNpTraining npResult
    
    puts "ITERATION #3 NEW CONTEXT RULES"
    
    ctxResult = contextIteration
    updateCtxTraining ctxResult
    
    puts "ITERATION #3 NEW NP RULES"
    
    npResult = npIteration
    updateNpTraining npResult
    
  end
  
  def reset
    @trainingInst.each do |train|
      train.tclass = nil
    end
    
    resetRules
    
    setInitialSeeds @rules, @trainingInst
  end
  
  def allTclasses
    tclasses = []
    @rules.each do |rule|
      if !(tclasses.any? {|t| t == rule.tclass})
        tclasses.push rule.tclass
      end
    end
    tclasses
  end
  
  #handle NP Iteration
  def npIteration
    npIterResults = []
    
    npWords.each do |word|
      count = 0
      npHash = { }
      
      @trainingInst.select{|t| t.tclass != nil}.each do |train|
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
      
      if count > 0
        npHash["count"] = count
        npHash["word"] = word
        npIterResults.push npHash
      end
      #puts "found #{count} of #{word}!"
    end
    npIterResults
  end
  
  def updateNpTraining(npIterResults)
    countedIters = []
    npIterResults.select{|t| t["count"] >= 2}.each do |npIter|
      count = npIter["count"]
      word = npIter["word"]
      
      allTclasses.each do |tclass|
        
        if npIter.has_key?(tclass) && ((npIter[tclass].to_f / count.to_f) >= 0.8)
          # greater than 80%?
          # update everyone with the same ctx
          @trainingInst.select{|t| t.tclass == nil}.each do |train|
            #puts "context -> #{train.context}... tclass -> #{tclass}"
            if (train.npSplit.any?{|t| t == word})
              puts "changed #{train.np} & #{train.context} -> #{tclass}"
              train.tclass = tclass
            end
          end
          
          newRule = Rule.new
          newRule.type = "CONTEXT"
          newRule.contains = word
          newRule.tclass = tclass
          
          if @rules.any?{|t| t.type != newRule.type && newRule.contains != t.contains && t.tclass != newRule.tclass}
            newRule.putSelf
            @rules.push newRule
          end
        end
      end
    end
  end
  #end NP Iteration
  
  #handle CONTEXT Iteration
  def contextIteration
    ctxIterResults = []
    
    contextWords.each do |word|
      count = 0
      ctxHash = { }
      
      @trainingInst.select{|t| t.tclass != nil}.each do |train|
        train.contextSplit.each do |ctx|
          #puts "comparing #{ctx} vs #{word}..."
          if ctx == word
            #puts "success!"
            count = count + 1
            
            if ctxHash.has_key? train.tclass
              ctxHash[train.tclass] = ctxHash[train.tclass] + 1
            else
              ctxHash[train.tclass] = 1
            end
          end
        end
      end
      
      if count > 0
        ctxHash["count"] = count
        ctxHash["word"] = word
        ctxIterResults.push ctxHash
      end
      #puts "found #{count} of #{word}!"
    end
    ctxIterResults
  end
  
  def updateCtxTraining(ctxIterResults)
    countedIters = []
    ctxIterResults.select{|t| t["count"] >= 2}.each do |ctxIter|
      count = ctxIter["count"]
      word = ctxIter["word"]
      
      allTclasses.each do |tclass|
        
        if ctxIter.has_key?(tclass) && ((ctxIter[tclass].to_f / count.to_f) >= 0.8)
          # greater than 80%?
          # update everyone with the same ctx
          @trainingInst.select{|t| t.tclass == nil}.each do |train|
            #puts "context -> #{train.context}... tclass -> #{tclass}"
            if (train.contextSplit.any?{|t| t == word})
              #puts "changed #{train.np} & #{train.context} -> #{tclass}"
              train.tclass = tclass
            end
          end
          
          newRule = Rule.new
          newRule.type = "CONTEXT"
          newRule.contains = word
          newRule.tclass = tclass
          
          if @rules.any?{|t| t.type != newRule.type && newRule.contains != t.contains && t.tclass != newRule.tclass}
            newRule.putSelf
            @rules.push newRule
          end
        end
      end
    end
  end
  #end CONTEXT Iteration
  
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
  
  def setInitialSeeds(rules, trInstances)
    rules.select{|t| t.type == "NP"}.each do |rule|
      pregex = Regexp.new rule.contains

      trInstances.each do |instance|
        #puts "np: #{instance.np}"
        instance.npSplit.each do |word|
          #puts "word: #{word} - regex: #{pregex}"
          if (word =~ pregex) != nil
            #puts "Success! Setting instance #{instance.tclass} to #{rule.tclass}"
            instance.tclass = rule.tclass
          end
        end
      end
    end

    rules.select{|t| t.type == "CONTEXT"}.each do |rule|
      pregex = Regexp.new rule.contains

      trInstances.each do |instance|
        #puts "context: #{instance.np}"
        instance.contextSplit.each do |word|
          #puts "word: #{word} - regex: #{pregex}"
          if (word =~ pregex) != nil
            #puts "Success! Setting instance #{instance.tclass} to #{rule.tclass}"
            instance.tclass = rule.tclass
          end
        end
      end
    end
  end
end