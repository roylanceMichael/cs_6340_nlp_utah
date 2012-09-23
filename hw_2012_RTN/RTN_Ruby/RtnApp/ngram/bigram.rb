class Bigram
  attr_accessor :n, :n_minus_1
  
  def ==(anotherBigram)
    if anotherBigram == nil
      return false
    end
    return anotherBigram.n == @n && anotherBigram.n_minus_1 == @n_minus_1
  end
end