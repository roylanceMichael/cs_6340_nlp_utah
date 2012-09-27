class Sentence
  attr_accessor :words
  
  def initialize(content)
		@words = []
		splitWords = content.lstrip.rstrip.split /\s+/
		splitWords.each do |foundWord|
	    @words.push foundWord.downcase
    end
  end
  
  def printself
    str = ""
    @words.each do |word|
      str = "#{str} #{word.rawWord}"
    end
    str
  end
  
  def generateunigrams
    if @words.length == 0
      return []
    end
    
    unigrams = []
    @words.each do |word|
      unigrams.push word
    end
    
    unigrams
  end
  
  def generatebigrams
    if @words.length == 0
      return []
    end
    
    bigrams = []
    previousWord = nil
    
    @words.each do |word|
      bigrams.push [previousWord, word]
      previousWord = word
    end
    
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
      trigrams.push [previouspreviousWord, previousWord, word]
      previouspreviousWord = previousWord
      previousWord = word
    end
    
    trigrams
  end
  
  def self.factory(content)
    prop = /\n/
    sentences = []
    foundMatches = content.lstrip.rstrip.split prop
    foundMatches.each do |match|
      sentences.push Sentence.new match
    end
    sentences
  end
end