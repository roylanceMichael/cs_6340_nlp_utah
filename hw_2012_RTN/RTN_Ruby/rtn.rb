require './dm.rb'
require './rtnm.rb'
require './rule.rb'
require './sm.rb'
require './rule_tuple.rb'
require 'set'

#main level functions
if ARGV != nil && ARGV.length > 3
	puts ARGV[0]
	puts ARGV[1]
	puts ARGV[2]
	puts ARGV[3]
end

def vs(sentence, dict, rtnm)
	#expecting one head rtnm
	sm = Sm.new
	sm.sentence = sentence

	result = rtnm.first.as sm, dict, 0
	fr = result.select{|t| t.index == sm.words.length - 1}
	fr
end

def setRuleTypes(dict, rtnm)
	if dict == nil || rtnm == nil
		return
	end
	
	posSet = Set.new
	dict.each {|t| posSet.add? t.pos}
	
	allRules = []
	#select many
	
	rtnm.each do |m|
		m.rules.each do |r|
			#check out the arc, first, is it a machine?
			machineMatch = rtnm.select{|t| t.machinename == r.arcname}
			if machineMatch != nil && machineMatch.length > 0
				#found it!
				r.arctype = "machine"
				r.arcref = machineMatch.first
				next
			elsif posSet.include? r.arcname
				r.arctype = "word"
				#not sure what to do here...
				r.arcref = ""
			end
		end
	end
end