# examples/stats_report.rb
# frozen_string_literal: true

# Print a summary report of contacts in a .abbu archive
#
# Usage:
#   bundle exec ruby examples/stats_report.rb Contacts.abbu

require 'abbu'

archive  = Abbu.open(ARGV[0] || 'Contacts.abbu')
contacts = archive.contacts

puts '=== Contacts Report ==='
puts "Total contacts : #{contacts.count}"
puts "With email     : #{contacts.count { |c| c.emails.any? }}"
puts "With phone     : #{contacts.count { |c| c.phones.any? }}"
puts "With company   : #{contacts.count(&:company)}"
