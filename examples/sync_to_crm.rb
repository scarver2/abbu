# examples/sync_to_crm.rb
# frozen_string_literal: true

# Stub CRM sync pattern — replace CRM.upsert with your adapter
#
# Usage:
#   bundle exec ruby examples/sync_to_crm.rb Contacts.abbu

require 'abbu'

# Replace this class with your real CRM adapter (Printavo, HubSpot, Rodeo, etc.)
class CRM
  def self.upsert(contact)
    puts "Syncing #{contact.full_name}"
  end
end

archive = Abbu.open(ARGV[0] || 'Contacts.abbu')

archive.contacts.each do |c|
  CRM.upsert(c)
end
