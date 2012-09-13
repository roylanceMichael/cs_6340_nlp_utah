class Sm
	attr_accessor :sentence, :index, :history
	
	def record(rule)
		if @history == nil
			@history = []
		end
		@index = @index + 1
		@history.push "#{rule.start} - #{rule.arcname} - #{rule.end}"
	end
	
	def windex(index)
		if words == nil || index > words.length
			nil
		else
			words[index]
		end
	end
	
	def sentencesofar
		workspace = ''
		index = 0
		while index <= @index && words[index] != nil
			workspace = workspace + ' ' + words[index]
			index = index + 1
		end
		workspace.strip
	end
	
	def printhistory
		if @history != nil
			@history.each {|h| puts h}
		end
	end
	
	def words
		@sentence.split.select{|t| (t =~ /[0-9A-Za-z]+/) != nil}
	end
	
	def word
		if words == nil || @index > words.length
			nil
		else
			words[@index]
		end
	end
	
	def copy
		tempSm = Sm.new
		tempSm.sentence = @sentence
		tempSm.index = @index
		tempSm.history = @history
		tempSm
	end
end