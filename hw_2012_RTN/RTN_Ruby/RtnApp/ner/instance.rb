class Instance
  attr_accessor :context, :np
  
  def self.factory(content)
    splitContent = content.lstrip.rstrip.split /\n/
    
    instances = []
    tempInstance = Instance.new
    
    splitContent.each do |c|
      if tempInstance.context == nil && c != nil && c.length > 8
        tempInstance.context = c.slice(8, c.length - 8)
      elsif c != nil && c.length > 3
        tempInstance.np = c.slice(3, c.length - 3)
        instances.push tempInstance
        tempInstance = Instance.new
      end
    end
    
    instances
  end
end