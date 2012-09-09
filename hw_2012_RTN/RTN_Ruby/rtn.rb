require 'dm.rb'
require 'rtnm.rb'
require 'rule.rb'
require 'sm.rb'
require 'set'

def validateSentence(sentence, dict, rtnm)
	#right now, the start machine will be rtnm[0]
	
	sm = Sm.new
	sm.sentence = sentence
	sm.index = 0
	
	puts "PROCESSING SENTENCE: #{sm.sentence}"
	result = rtnm.first.applySentence sm, dict
	result != nil && result.length > 0
end

if ARGV != nil && ARGV.length > 3
	puts ARGV[0]
	puts ARGV[1]
	puts ARGV[2]
	puts ARGV[3]
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