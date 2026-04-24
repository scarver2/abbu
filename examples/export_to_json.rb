# examples/export_to_json.rb
# frozen_string_literal: true

# Export all contacts from a .abbu archive to contacts.json
#
# Usage:
#   bundle exec ruby examples/export_to_json.rb Contacts.abbu
#   bundle exec ruby examples/export_to_json.rb Contacts.abbu | jq .

require 'abbu'

archive = Abbu.open(ARGV[0] || 'Contacts.abbu')

Abbu::Exporters::JsonExporter
  .new(archive.contacts)
  .to_file('contacts.json')

puts "Exported #{archive.contacts.count} contacts to contacts.json"
