class Word
  attr_accessor :rawWord
  
  def filtered
    if @rawWord == nil
      ''
    else
      @rawWord =~ /[A-Za-z]+/
      $1
    end
  end
end