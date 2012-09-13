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
			tr.prettyprint sm
			puts "           "
		end
		true
	end
	
	def jt
    #arrange
		rtnm = Rtnm.factory 'rtnspecs.txt'
		dict = Dm.factory 'dict.txt'
		
		setRuleTypes(dict, rtnm)
		
		sentence = "john"
		
		#act
		result = vs sentence, dict, rtnm
		
		#assert
		sm = Sm.new
		sm.sentence = sentence
		result.each do |tr|
			tr.prettyprint sm
			puts "           "
		end
		true
  end
  
  def jwt
    #arrange
		rtnm = Rtnm.factory 'rtnspecs.txt'
		dict = Dm.factory 'dict.txt'
		
		setRuleTypes(dict, rtnm)
		
		sentence = "john walks"
		
		#act
		result = vs sentence, dict, rtnm
		
		#assert
		sm = Sm.new
		sm.sentence = sentence
		result.each do |tr|
			tr.prettyprint sm
			puts "           "
		end
		true
  end
  
  def ft
    #arrange
		rtnm = Rtnm.factory 'rtnspecs.txt'
		dict = Dm.factory 'dict.txt'
		
		setRuleTypes(dict, rtnm)
		
		sentence = "flies like smelly bananas"
		
		#act
		result = vs sentence, dict, rtnm
		
		#assert
		sm = Sm.new
		sm.sentence = sentence
		result.each do |tr|
			tr.prettyprint sm
			puts "           "
		end
		true
  end
  
  def fct
    #arrange
		rtnm = Rtnm.factory 'rtnspecs.txt'
		dict = Dm.factory 'dict.txt'
		
		setRuleTypes(dict, rtnm)
		
		sentence = "fruit flies like trees"
		
		#act
		result = vs sentence, dict, rtnm
		
		#assert
		sm = Sm.new
		sm.sentence = sentence
		result.each do |tr|
			tr.prettyprint sm
			puts "           "
		end
		true
  end
  
  def fzt
    #arrange
		rtnm = Rtnm.factory 'rtnspecs.txt'
		dict = Dm.factory 'dict.txt'
		
		setRuleTypes(dict, rtnm)
		
		sentence = "fruit flies like the pears in the trees"
		
		#act
		result = vs sentence, dict, rtnm
		
		#assert
		sm = Sm.new
		sm.sentence = sentence
		result.each do |tr|
			tr.prettyprint sm
			puts "           "
		end
		true
  end
end