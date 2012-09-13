class RuleTuple
	attr_accessor :rule, :index, :prev, :accept
	
	def same?(rt)
		if rt != nil && @rule != nil && rt.rule.start == @rule.start && rt.rule.end == @rule.end && rt.rule.arcname == @rule.arcname && rt.index == @index
			true
		else
			false
		end
	end
	
	def to_ps(sm)
    if @rule != nil && @rule.arctype == 'machine'
      "#{@rule.start} - #{@rule.arcname} -> #{@rule.end}"
    else
      "#{@rule.start} - #{@rule.arcname} (#{sm.windex @index}) -> #{@rule.end}"
    end
  end
	
	def printself(sm)
		puts self.to_ps sm
	end
	
	def history(sm)
		printself sm
		tempPrev = @prev
		while tempPrev != nil
			tempPrev.printself sm
			tempPrev = tempPrev.prev
		end
	end
	
	def prettyprint(sm)
	  puts "PROCESSING SENTENCE: #{sm.sentence}"
    stack = []
    stack.push self
    tempPrev = @prev
    while tempPrev != nil
      stack.push tempPrev
      tempPrev = tempPrev.prev
    end
    stack = stack.reverse
    stack.each{|t| t.printself sm}
    
    if @accept != nil
      puts @accept
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