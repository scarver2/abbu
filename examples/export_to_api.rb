# examples/export_to_api.rb
# frozen_string_literal: true

# Sync contacts from a .abbu archive to a JSON API (CRM / Rodeo pattern)
#
# Usage:
#   bundle exec ruby examples/export_to_api.rb Contacts.abbu

require 'abbu'
require 'net/http'
require 'json'

API_ENDPOINT = 'https://api.example.com/contacts'

archive = Abbu.open(ARGV[0] || 'Contacts.abbu')

archive.contacts.each do |c|
  uri = URI(API_ENDPOINT)

  response = Net::HTTP.post(
    uri,
    { name: c.full_name, email: c.emails.first, phone: c.phones.first }.to_json,
    'Content-Type' => 'application/json'
  )

  puts "#{c.full_name} → #{response.code}"
end
