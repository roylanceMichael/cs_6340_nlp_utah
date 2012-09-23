require './word.rb'
class Sentence
  attr_accessor :words
  
  def initialize(content)
		@words = []
		splitWords = content.split /\s+/
		splitWords.each do |foundWord|
	    word = Word.new
	    word.rawWord = foundWord
	    @words.push word
    end
  end
  
  def printself
    str = ""
    @words.each do |word|
      str = "#{str} #{word.rawWord}"
    end
    str
  end
  
  def generatebigrams
    if @words.length == 0
      return []
    end
    
    bigrams = []
    previousWord = nil
    
    @words.each do |word|
      normalizedWord = word.rawWord.downcase
      bigrams.push [previousWord, normalizedWord]
      previousWord = normalizedWord
    end
    
    bigrams.push [previousWord, nil]
    
    bigrams
  end
  
  def generatetrigrams
    if @words.length == 0
      return []
    end
    
    trigrams = []
    previouspreviousWord = nil
    previousWord = nil
    
    @words.each do |word|
      normalizedWord = word.rawWord.downcase
      trigrams.push [previouspreviousWord, previousWord, normalizedWord]
      previouspreviousWord = previousWord
      previousWord = normalizedWord
    end
    
    trigrams.push [previouspreviousWord, previousWord, nil]
    
    previouspreviousWord = previousWord
    previousWord = nil
    
    trigrams.push [previouspreviousWord, previousWord, nil]
    
    trigrams
  end
  
  def self.factory(content)
    prop = /\n/
    sentences = []
    foundMatches = content.split prop
    foundMatches.each do |match|
      sentences.push Sentence.new match
    end
    sentences
  end
end