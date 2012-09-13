require './dm.rb'
require './rtnm.rb'
require './rule.rb'
require './sm.rb'
require './rule_tuple.rb'

class Lib  
  def self.vs(sentence, dict, rtnm)
	  #expecting one head rtnm
	  sm = Sm.new
	  sm.sentence = sentence

	  result = rtnm.first.as sm, dict, 0, rtnm
	  fr = result.select{|t| t.index == sm.words.length - 1}
	  fr
  end

  def self.setRuleTypes(dict, rtnm)
	  if dict == nil || rtnm == nil
		  return
	  end
	
	  posSet = []
	  dict.each do |t|
      if !(posSet.any?{|f| f == t.pos })
        posSet.push t.pos
      end
    end
	
	  allRules = []
	  #select many
	
	  rtnm.each do |m|
		  m.rules.each do |r|
			  #check out the arc, first, is it a machine?
			  machineMatch = rtnm.select{|t| t.machinename == r.arcname}
			  if machineMatch != nil && machineMatch.length > 0
				  r.arctype = "machine"
				  next
			  elsif posSet.include? r.arcname
				  r.arctype = "word"
			  end
		  end
	  end
  end
end