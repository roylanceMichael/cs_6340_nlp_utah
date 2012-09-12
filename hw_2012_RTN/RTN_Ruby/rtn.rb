require 'dm.rb'
require 'rtnm.rb'
require 'rule.rb'
require 'sm.rb'
require 'set'

def vs(sentence, dict, rtnm)
	altpaths = []
	chart = []
	#expecting one head rtnm
	sm = Sm.new
	sm.sentence = sentence
	
	result = rtnm.first.as sm, dict, 0
	puts "#########################################"
	fr = result.select{|t| t.index == sm.words.length}
	puts fr.length
	fr
end


def validateSentence(sentence, dict, rtnm)
	#right now, the start machine will be rtnm[0]
	
	sm = Sm.new
	sm.sentence = sentence
	sm.index = 0
	
	puts "PROCESSING SENTENCE: #{sm.sentence}"
	
	result = rtnm.first.applySentence sm, dict
	
	result.each do |r|
		puts "#{r.sm.printhistory}"
	end
	#result
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

class RuleTuple
	attr_accessor :rule, :index, :prev
	
	def same?(rt)
		if rt != nil && @rule != nil && rt.rule.start == @rule.start && rt.rule.end == @rule.end && rt.rule.arcname == @rule.arcname && rt.index == @index
			true
		else
			false
		end
	end
	
	def printself(sm)
		puts "#{rule.start} - #{rule.arcname} - #{rule.end} - #{sm.windex index} - #{index}"
	end
	
	def history(sm)
		printself sm
		tempPrev = @prev
		while tempPrev != nil
			tempPrev.printself(sm)
			tempPrev = tempPrev.prev
		end
	end
	
	def copy
		tr = RuleTuple.new
		tr.rule = @rule
		tr.index = @index
		if @prev != nil
			tr.prev = @prev.copy
		end
		tr
	end
	
	def root
		tempPrev = self
		while tempPrev != nil
			if tempPrev.prev == nil
				return tempPrev
			else
				tempPrev = tempPrev.prev
			end
		end
	end
end

class Chart
	attr_accessor :cstate, :index, :rstate, :arc
end