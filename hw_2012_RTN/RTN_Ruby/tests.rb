require './rtn.rb'
class Tests
	attr_accessor :dict, :rtnm
	
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
		sm = Sm.new
		sm.sentence = sentence
		result.each do |tr|
			tr.history sm
			puts "           "
		end
		true
	end
end