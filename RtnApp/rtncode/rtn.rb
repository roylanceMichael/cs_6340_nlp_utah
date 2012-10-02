require './lib.rb'
require './dm.rb'
require './rtnm.rb'
require './sm.rb'
require './rule_tuple.rb'
require './rule.rb'

#main level functions
if ARGV != nil && ARGV.length > 2
  puts "trying to process the dictionary: #{ARGV[0]}, rtnspec: #{ARGV[1]} and test file: #{ARGV[2]}"
  dict = Dm.factory ARGV[0]
  rtnm = Rtnm.factory ARGV[1]
  Lib.setRuleTypes dict, rtnm
  
  rawFile = File.new(ARGV[2])
  while line = rawFile.gets
    puts "PROCESSING SENTENCE: #{line}"
    puts "           "
    result = Lib.vs line, dict, rtnm
    sm = Sm.new
    sm.sentence = line
		result.each do |tr|
		  puts "SUCCESSFUL PARSE"
			tr.prettyprint sm
			puts "           "
		end
		puts "Done! Found #{result.length} parse(s)."
		puts "           "
  end
end
