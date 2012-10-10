class Rule
  attr_accessor :type, :contains, :tclass
  
  def printSelf
    "#{@type} Contains(#{@contains}) -> #{@tclass}"
  end
  
  def putSelf
    puts printSelf
  end
  
  def self.if(fileLocation)
    str = (File.new fileLocation).read
    result = Rule.factory str
    result
  end
  
  def self.factory(content)
    sContent = content.split /\n/
    regEx = /\s*(.+?)\s+Contains\((.+?)\)\s+->\s+(.+?)\s*/
    
    rules = []
    
    sContent.each do |s|
      match = regEx.match s
      type = match[1].lstrip.rstrip
      contains = match[2].lstrip.rstrip
      tclass = match[3].lstrip.rstrip
      rule = Rule.new
      rule.type = type == "SPELLING" ? "NP" : "CONTEXT"
      rule.contains = contains
      rule.tclass = tclass
      rules.push rule
    end
    
    rules
  end
end