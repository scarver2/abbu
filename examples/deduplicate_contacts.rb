# examples/deduplicate_contacts.rb
# frozen_string_literal: true

# Find duplicate contacts by email address
#
# Usage:
#   bundle exec ruby examples/deduplicate_contacts.rb Contacts.abbu

require 'abbu'
require 'abbu/utils/deduplicator'

archive = Abbu.open(ARGV[0] || 'Contacts.abbu')

dupes = Abbu::Utils::Deduplicator.new(archive.contacts).duplicates

if dupes.empty?
  puts 'No duplicates found.'
else
  puts "Found #{dupes.size} duplicate email(s):\n\n"
  dupes.each do |email, contacts|
    puts "Duplicate: #{email}"
    contacts.each { |c| puts "  - #{c.full_name}" }
    puts
  end
end
