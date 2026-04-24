# examples/export_to_vcard.rb
# frozen_string_literal: true

# Export all contacts from a .abbu archive to contacts.vcf
#
# Usage:
#   bundle exec ruby examples/export_to_vcard.rb Contacts.abbu

require 'abbu'

archive = Abbu.open(ARGV[0] || 'Contacts.abbu')

Abbu::Exporters::VcardExporter
  .new(archive.contacts)
  .to_file('contacts.vcf')

puts "Exported #{archive.contacts.count} contacts to contacts.vcf"
