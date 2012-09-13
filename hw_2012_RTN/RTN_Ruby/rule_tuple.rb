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