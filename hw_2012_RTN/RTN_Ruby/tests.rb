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
			current = tr
			puts "---------------------------------"
			while current != nil
				puts current.printself sm
				current = current.prev
			end
			puts "---------------------------------"
		end
		true
	end
end