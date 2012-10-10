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
  attr_accessor :rules, :trainingInst, :testInst
  
  def initialize(initRules, trainingInst, testInst)
    @rules = initRules
    @trainingInst = trainingInst
    @testInst = testInst
    
    setInitialSeeds initRules, trainingInst
  end
  
  def reset
    puts @trainingInst
    @trainingInst.each do |train|
      train.tclass = nil
    end
    
    setInitialSeeds @rules, @trainingInst
  end
  
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
        puts "np: #{instance.np}"
        instance.npSplit.each do |word|
          puts "word: #{word} - regex: #{pregex}"
          if (word =~ pregex) != nil
            puts "Success! Setting instance #{instance.tclass} to #{rule.tclass}"
            instance.tclass = rule.tclass
          end
        end
      end
    end

    rules.select{|t| t.type == "CONTEXT"}.each do |rule|
      pregex = Regexp.new rule.contains

      trInstances.each do |instance|
        puts "context: #{instance.np}"
        instance.contextSplit.each do |word|
          puts "word: #{word} - regex: #{pregex}"
          if (word =~ pregex) != nil
            puts "Success! Setting instance #{instance.tclass} to #{rule.tclass}"
            instance.tclass = rule.tclass
          end
        end
      end
    end
  end
end

def npTest(rules, trInstances)
  rules.each do |rule|
    
    pregex = Regexp.new rule.contains
    
    trInstances.each do |instance|
      puts "np: #{instance.np}"
      instance.npSplit.each do |word|
        puts "word: #{word} - regex: #{pregex}"
        if (word =~ pregex) != nil
          puts "Success! Setting instance #{instance.tclass} to #{rule.tclass}"
          instance.tclass = rule.tclass
        end
      end
    end
  end
end