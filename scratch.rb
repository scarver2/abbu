require 'pathname'
path = Pathname.new('/Users/scarver2/Library/Application Support/AddressBook')
puts "Root dbs: #{path.glob('*.abcddb').map(&:to_s)}"
puts "All dbs: #{path.glob('**/*.abcddb').map(&:to_s)}"
