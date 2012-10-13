if ARGV != nil && ARGV.length > 2
  load 'instance.rb'
  load 'rule.rb'
  load 'nerc.rb'
  seedsStr = (File.new ARGV[0]).read
  trainingStr = (File.new ARGV[1]).read
  testStr = (File.new ARGV[2]).read
  
  initialRules = Rule.factory seedsStr
  trInstances = Instance.factory trainingStr
  test = Instance.factory testStr
  
  ner = Ner.new initialRules, trInstances, test
  puts ner.execute
end
