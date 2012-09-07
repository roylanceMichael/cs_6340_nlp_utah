require 'dm.rb'
require 'rtnm.rb'
require 'rule.rb'

if ARGV != nil && ARGV.length > 3
	puts ARGV[0]
	puts ARGV[1]
	puts ARGV[2]
	puts ARGV[3]
	puts Rtnm.new
end

