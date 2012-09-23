class Ngram
  attr_accessor :sentences, :unigram, :bigram, :trigram
  
  def initialize(sentences)
    if sentences == nil
      puts "sentences must not be nil!"
      return
    end
    @sentences = sentences

    #creates the first hash for unigrams
    @unigram = Hash.new
    @bigram = Hash.new
    @trigram = Hash.new
    
    sentences.each do |sentence|
      createunigram(sentence)
      createbigram(sentence)
      createtrigram(sentence)
    end
    true
  end
  
  def createunigram(sentence)
    if sentence == nil
      return
    end
    sentence.words.each do |word|
      normalizedWord = word.rawWord.downcase
      if normalizedWord == ""
        next
      end
      
      if @unigram.has_key? normalizedWord
        @unigram[normalizedWord] = @unigram[normalizedWord] + 1
      else
        @unigram[normalizedWord] = 1
      end
    end
  end
  
  def createbigram(sentence)
    if sentence == nil
      return
    end
    
    sentenceBigrams = sentence.generatebigrams
    
    sentenceBigrams.each do |foundBigram|
      if @bigram.has_key? foundBigram
        @bigram[foundBigram] = @bigram[foundBigram] + 1
      else
        @bigram[foundBigram] = 1
      end
    end
  end
  
  def createtrigram(sentence)
    if sentence == nil
      return
    end
    
    sentenceTrigrams = sentence.generatetrigrams
    
    sentenceTrigrams.each do |foundTrigram|
      if @trigram.has_key? foundTrigram
        @trigram[foundTrigram] = @trigram[foundTrigram] + 1
      else
        @trigram[foundTrigram] = 1
      end 
    end
  end
  
  def printuni
    @unigram.each do |k, v|
      puts "#{k} - #{v}"
    end
  end
  
  def unilength
    totalCount = 0
    @unigram.each {|k, v| totalCount = totalCount + v }
    totalCount
  end
  
  def bilength
    totalCount = 0
    @bigram.each {|k, v| totalCount = totalCount + v }
    totalCount
  end
  
  def trilength
    totalCount = 0
    @trigram.each {|k, v| totalCount = totalCount + v }
    totalCount
  end
  
  def puni(word)
    normalizedWord = word.downcase
    if !@unigram.has_key? normalizedWord
      return 0
    end

    puts "totalCount is #{unilength}"
    puts "wordFreq is #{@unigram[normalizedWord]}"
    
    wordFreq = @unigram[normalizedWord]
    (Math.log2 wordFreq.to_f / unilength.to_f).round(4)
  end
end