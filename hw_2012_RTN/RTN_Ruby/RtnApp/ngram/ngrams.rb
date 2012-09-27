require './sentence.rb'
require './ngram.rb'

#main level functions
if ARGV != nil && ARGV.length > 2
  puts "trying to process the training: #{ARGV[0]}, test: #{ARGV[1]} and seeds: #{ARGV[2]}"
  
  sentences = Sentence.factory (File.new ARGV[0]).read
  testSentences = (File.new ARGV[1]).read.strip.split(/\n/)
  seeds = ((File.new ARGV[2]).read).split(/\s+/)
  
  ngram = Ngram.new sentences
  
  testSentences.each do |testSentence|
    puts "S = #{testSentence}"
    puts "   "
    puts ngram.prob testSentence
    puts "   "
  end
  
  seeds.each do |seed|
    puts "Seed Word = #{seed}"
    puts "   "
    for i in 1..10
      puts "Sentence #{i}: #{ngram.languagegen(seed.strip)[0]}"
    end
    puts "   "
  end
end