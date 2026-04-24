# examples/export_to_csv.rb
# frozen_string_literal: true

# Export all contacts from a .abbu archive to contacts.csv
#
# Usage:
#   bundle exec ruby examples/export_to_csv.rb Contacts.abbu

require 'abbu'
require 'csv'

archive = Abbu.open(ARGV[0] || 'Contacts.abbu')

CSV.open('contacts.csv', 'w') do |csv|
  csv << %w[Name Email Phone Company]

  archive.contacts.each do |c|
    csv << [c.full_name, c.emails.first, c.phones.first, c.company]
  end
end

puts "Exported #{archive.contacts.count} contacts to contacts.csv"
