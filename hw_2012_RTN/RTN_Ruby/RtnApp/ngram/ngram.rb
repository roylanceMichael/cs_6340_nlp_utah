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
      if word == ""
        next
      end
      
      if @unigram.has_key? word
        @unigram[word] = @unigram[word] + 1
      else
        @unigram[word] = 1
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
  
  def prob(s)
    sentence = Sentence.new s
    
    unigrams = sentence.generateunigrams
    
    uniprob = calculateprob unigrams, unilength, @unigram
    returnString = "Unigrams: logprob(S) = #{uniprob}"
    
    bigrams = sentence.generatebigrams
    biprob = calculatebiprob bigrams, @bigram
    returnString = "#{returnString}\nBigrams: logprob(S) = #{biprob}"
    
    trigrams = sentence.generatetrigrams
    triprob = calculatetriprob trigrams, @trigram
    returnString = "#{returnString}\nTrigrams: logprob(S) = #{triprob}"
    
    bismoothed = smoothedbiprob bigrams, @bigram
    returnString = "#{returnString}\nSmoothed Bigrams: logprob(S) = #{bismoothed}"
    
    trismoothed = smoothedtriprob trigrams, @trigram
    returnString = "#{returnString}\nSmoothed Trigrams: logprob(S) = #{trismoothed}"
    
    returnString
  end
  
  def smoothedbiprob(grams, hash)
    prob = 1.to_f
    uniq = unigram.length
    #puts unigram.length
    grams.each do |gram|
      length = uniq
      hash.select {|k, v| k[0] == gram[0]}.each{|k, v| length = length + v}
      freq = 1
      hash.select {|k, v| k[0] == gram[0] && k[1] == gram[1]}.each{|k, v| freq = freq + v}
      #puts "#{gram} -> freq: #{freq} length: #{length}"
      prob = prob * (freq.to_f / length.to_f)
    end
    #puts "prob: #{prob}"
    (Math.log2 prob).round(4)
  end
  
  def smoothedtriprob(grams, hash)
    prob = 1.to_f
    uniq = unigram.length
    grams.each do |gram|
      length = uniq
      hash.select {|k, v| k[0] == gram[0] && k[1] == gram[1]}.each{|k, v| length = length + v}
      freq = 1
      hash.select {|k, v| k[0] == gram[0] && k[1] == gram[1] && k[2] == gram[2]}.each{|k, v| freq = freq + v}
      #puts "#{gram} -> freq: #{freq} length: #{length}"
      prob = prob * (freq.to_f / length.to_f)
    end
    #puts "prob: #{prob}"
    (Math.log2 prob).round(4)
  end
  
  def calculatetriprob(grams, hash)
    prob = 1.to_f
    grams.each do |gram|
      length = 0
      hash.select {|k, v| k[0] == gram[0] && k[1] == gram[1]}.each{|k, v| length = length + v}
      freq = 0
      hash.select {|k, v| k[0] == gram[0] && k[1] == gram[1] && k[2] == gram[2]}.each{|k, v| freq = freq + v}
      #puts "#{gram} -> freq: #{freq} length: #{length}"
      if length != 0 && freq != 0
        prob = prob * (freq.to_f / length.to_f)
      else
        prob = "undefined"
        break
      end
    end
    #puts "prob: #{prob}"
    prob = prob == 'undefined' ? prob : (Math.log2 prob).round(4)
    prob
  end
  
  def calculatebiprob(grams, hash)
    prob = 1.to_f
    grams.each do |gram|
      length = 0
      hash.select {|k, v| k[0] == gram[0]}.each{|k, v| length = length + v}
      freq = 0
      hash.select {|k, v| k[0] == gram[0] && k[1] == gram[1]}.each{|k, v| freq = freq + v}
      #puts "#{gram} -> freq: #{freq} length: #{length}"
      if length != 0 && freq != 0
        prob = prob * (freq.to_f / length.to_f)
      else
        prob = "undefined"
        break
      end
    end
    #puts "prob: #{prob}"
    prob = prob == 'undefined' ? prob : (Math.log2 prob).round(4)
    prob
  end
  
  def calculateprob(grams, length, hash)
    prob = 1.to_f
    grams.each do |gram|
      if hash.has_key? gram
        #puts "#{gram} : #{hash[gram].to_f / length.to_f}"
        prob = prob * (hash[gram].to_f / length.to_f)
      else
        prob = "undefined"
        break
      end
    end
    #puts "prob: #{prob}"
    prob = prob == 'undefined' ? prob : (Math.log2 prob).round(4)
    prob
  end
  
  def unilength
    totalCount = 0
    @unigram.each {|k, v| totalCount = totalCount + v }
    totalCount
  end
end