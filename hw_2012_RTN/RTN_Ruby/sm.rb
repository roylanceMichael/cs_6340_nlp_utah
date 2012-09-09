class Sm
	attr_accessor :sentence, :index

	def words
		@sentence.split
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
		tempSm
	end
end