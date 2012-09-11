require './rtn.rb'
class Tests
	attr_accessor :dict, :rtnm
	
	def runAll(dictFile, rtnmFile)
		
		@dict = Dm.factory dictFile
		@rtnm = Rtnm.factory rtnmFile
		
		setRuleTypes(@dict, @rtnm)
		
		allTests = self.method.select{|t| (t.to_s =~ /Test/) != nil}
		allTests.each do |test|
			puts "executing #{test}, result is #{self.send test}"
		end
	end
	
	def buildMachine
		rtnm = Rtnm.new
		rtnm.machinename = "S"
		rtnm.init = "S1"
		rtnm.final = ["S2"]
		
		rule = Rule.new
		rule.start = "S1"
		rule.end = "S2"
		rule.arcname = "noun"
		rule.arctype = "word"
		rule.parentmachine = rtnm

		rtnm.rules = [rule]
		rtnm
	end
	
	def buildDict
		dict = Dm.new
		dict.word = "awesome"
		dict.pos = "noun"
		dict
	end
	
	def simpleMachineDict
		rtnm = buildMachine
		dict = buildDict
		
		returnMe = Hash.new
		returnMe[:rtnm] = [rtnm]
		returnMe[:dict] = [dict]
		
		setRuleTypes(returnMe[:dict], returnMe[:rtnm])

		returnMe
	end
	
	
	def simpleTest
		#arrange
		models = simpleMachineDict
		sentence = "awesome"
		
		#act
		result = validateSentence sentence, models[:dict], models[:rtnm]
		
		#assert
		result
	end
	
	def indepthTest
		#arrange
		rtnm = Rtnm.new
		rtnm.machinename = "Z"
		rtnm.init = "Z1"
		rtnm.final = ["Z2"]
		
		rule = Rule.new
		rule.start = "Z1"
		rule.end = "Z2"
		rule.arcname = "S"
		rule.arctype = "machine"
		
		rtnm.rules = [rule]
		
		rtnm1 = buildMachine
		dict = buildDict
		
		rule.arcref = rtnm1
		
		sentence = "awesome"
		
		#act
		result = validateSentence sentence, [dict], [rtnm, rtnm1]
		
		#assert 
		result
	end
	
	def emptyTest
		#arrange
		rtnm = Rtnm.factory 'rtnspecs.txt'
		dict = Dm.factory 'dict.txt'
		
		setRuleTypes(dict, rtnm)
		
		sentence = ""
		
		#act
		result = validateSentence sentence, dict, rtnm
		
		#assert
		
		result
	end
	
	def oneWordTest
		#arrange
		rtnm = Rtnm.factory 'rtnspecs.txt'
		dict = Dm.factory 'dict.txt'
		
		setRuleTypes(dict, rtnm)
		
		sentence = "the"
		
		#act
		result = validateSentence sentence, dict, rtnm
		
		#assert
		
		result
	end
	
	def t
		#arrange
		rtnm = Rtnm.factory 'rtnspecs.txt'
		dict = Dm.factory 'dict.txt'
		
		setRuleTypes(dict, rtnm)
		
		sentence = "the dog walks"
		
		#act
		result = validateSentence sentence, dict, rtnm
		
		#assert
		
		result
	end
	
	def r
		#arrange
		rtnm = Rtnm.factory 'lecRtn.txt'
		dict = Dm.factory 'lecDict.txt'
		
		setRuleTypes(dict, [rtnm[1]])
		
		sentence = "the metal blue"
		
		#act
		result = vs sentence, dict, [rtnm[1]]
		
		#assert
		puts sentence
		result.each do |tr|
			current = tr.prev
			puts "---------------------------------"
			while current != nil
				puts current.printself
				current = current.prev
			end
			puts "---------------------------------"
		end
		true
	end
	
	def st
		#arrange
		rtnm = Rtnm.factory 'lecRtn.txt'
		dict = Dm.factory 'lecDict.txt'
		
		setRuleTypes(dict, rtnm)
		
		sentence = "the metal can was dark blue"
		
		#act
		result = vs sentence, dict, rtnm
		
		#assert
		puts sentence
		puts result.length
		result.each do |tr|
			current = tr
			puts "---------------------------------"
			while current != nil
				puts current.printself
				current = current.prev
			end
			puts "---------------------------------"
		end
		true
	end
	
	
end